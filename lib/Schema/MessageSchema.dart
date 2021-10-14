/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-06 16:43:28
 * @modify date 2021-10-06 16:43:28
 * @desc [description]
 */

enum DataType {
  stringType,
  arrayType,
  numberType,
  booleanType,
  customObjectType,
  enumType,
}
/**
abstract class Constraint {}
abstract class LogicUnit extends Constraint {}
//Logic
class AndLogic extends LogicUnit {
  final List<Constraint> values;
  AndLogic(this.values);
}
class OrLogic extends LogicUnit {
  final List<Constraint> values;
  OrLogic(this.values);
}
class NotLogic extends LogicUnit {
  final Constraint value;
  NotLogic(this.value);
}
//Numbers
class NumberConstraint extends Constraint {}
class EqualConstraint extends NumberConstraint {
  final double value;
  EqualConstraint(this.value);
}
class GreaterConstraint extends NumberConstraint {
  final double value;
  GreaterConstraint(this.value);
}
class LessConstraint extends NumberConstraint {
  final double value;
  LessConstraint(this.value);
}
class InConstraint extends NumberConstraint {
  final List<double> values;
  InConstraint(this.values);
}
class BetweenConstraint extends NumberConstraint {
  final double first;
  final double last;
  BetweenConstraint(this.first, this.last);
}
    */
class ValidationResult {
  final bool passed;
  final String? message;
  ValidationResult(this.passed, {this.message});
  factory ValidationResult.passed(){
    final result = ValidationResult(true);
    return result;
  }
  factory ValidationResult.error(String message) {
    final result = ValidationResult(false, message: message);
    return result;
  }
}
abstract class ObjectSchema {
  final String? description;
  final bool nullable;
  final DataType type;
  ObjectSchema(this.type, this.nullable, {this.description});
  ValidationResult validate(String propertyName, Object? value);
  // Map<String, dynamic> serialize() => {
  //   "type": this.type,
  //   "description": this.description,
  //
  // };
}
//(root.girlFriends[20].name.length > 3 && root.girlFriends[20].name.length > 3) is not true.
class IntegerSchema extends ObjectSchema {
  final int minimumValue;
  final int maximumValue;
  IntegerSchema(bool nullable, this.maximumValue, this.minimumValue, {String? description}) : super(DataType.numberType, nullable, description: description);

  @override
  ValidationResult validate(String propertyName, Object? value) {
    final isRightType = value is int || value is int?;
    if (!isRightType) return ValidationResult.error("${propertyName}.runtimeType == ${this.nullable ? "int?" : "int"}");
    if (this.nullable && value == null) return ValidationResult.passed();
    if (!this.nullable && value == null) return ValidationResult.error("$propertyName != null");
    final isInRange = value as int <= maximumValue && value >= minimumValue;
    if (!isInRange) return ValidationResult.error("$propertyName >= ${this.minimumValue} && $propertyName <= ${this.maximumValue}");
    return ValidationResult.passed();
  }
  // @override
  // Map<String, dynamic> serialize() => {
  //   "type": this.type.toString(),
  //   "minimumValue": this.minimumValue,
  //   "maximumValue": this.maximumValue,
  // };
}

class DoubleSchema extends ObjectSchema {
  final double minimumValue;
  final double maximumValue;
  DoubleSchema(bool nullable, this.maximumValue, this.minimumValue, {String? description}) : super(DataType.numberType, nullable, description: description);

  @override
  ValidationResult validate(String propertyName, Object? value) {
    final isRightType = value is num || value is num?;
    if (!isRightType) return ValidationResult.error("${propertyName}.runtimeType == ${this.nullable ? "double?|int?" : "double|int"}");
    if (this.nullable && value == null) return ValidationResult.passed();
    if (!this.nullable && value == null) return ValidationResult.error("$propertyName != null");
    final isInRange = value as num <= maximumValue && value >= minimumValue;
    if (!isInRange) return ValidationResult.error("$propertyName >= ${this.minimumValue} && $propertyName <= ${this.maximumValue}");
    return ValidationResult.passed();
  }
}
class BooleanSchema extends ObjectSchema {
  BooleanSchema(bool nullable) : super(DataType.booleanType, nullable);

  @override
  ValidationResult validate (String propertyName, Object? value) {
    if (!(value is bool || value is bool?)) return ValidationResult.error("$propertyName.runtimeType == ${this.nullable ? "bool?" : "bool"}");
    if (!this.nullable && value == null) return ValidationResult.error("$propertyName != null");
    return ValidationResult.passed();
  }
}
class StringSchema extends ObjectSchema {
  final int minimumLength;
  final int maximumLength;
  StringSchema(bool nullable, this.minimumLength, this.maximumLength, {String? description}) : super(DataType.stringType, nullable, description: description);

  @override
  ValidationResult validate(String propertyName, Object? value) {
    final isValidType = value is String || value is String?;
    if (!isValidType) return ValidationResult.error("${propertyName}.runtimeType == ${this.nullable ? "String?" : "String"}");
    if (this.nullable && value == null) return ValidationResult.passed();
    if (this.nullable == false && value == null) return ValidationResult.error("$propertyName != null");
    final isValidLength = (value as String).length <= maximumLength && value.length >= minimumLength;
    if (!isValidLength) return ValidationResult.error("$propertyName.length <= ${this.maximumLength} && $propertyName.length >= ${this.minimumLength}");
    return ValidationResult.passed();
  }
}

class ArraySchema extends ObjectSchema {
  final ObjectSchema childrenSchema;
  final int minimumItemsCount;
  final int maximumItemsCount;
  ArraySchema(bool nullable, this.childrenSchema, this.minimumItemsCount, this.maximumItemsCount, {String? description}) : super(DataType.arrayType, nullable, description: description);

  @override
  ValidationResult validate(String propertyName, Object? value) {
    final isList = value is List || value is List?;
    if (!isList) return ValidationResult.error("$propertyName.runtimeType == ${this.nullable ? "List?" : "List"}");
    if (value == null && this.nullable == false) return ValidationResult.error("$propertyName != null");
    if (this.nullable && value == null) return ValidationResult.passed();
    final isValidLength = (value as List).length >= this.minimumItemsCount && value.length <= this.maximumItemsCount;
    if (!isValidLength) return ValidationResult.error("$propertyName.length >= ${this.minimumItemsCount} && $propertyName.length <= ${this.maximumItemsCount}");
    ValidationResult? result;
    var index = 0;
    for (final item in value) {
      result = this.childrenSchema.validate("$propertyName[$index]", item);
      index++;
      if (!result.passed) break;
    }
    result ??= ValidationResult.passed();
    return result;
  }
}

class CustomObjectSchema extends ObjectSchema {
  final Map<String, ObjectSchema> properties;
  CustomObjectSchema(bool nullable, this.properties) : super(DataType.customObjectType, nullable);

  @override
  ValidationResult validate(String propertyName, Object? value) {
    final isMap = value is Map<String, dynamic> || value is Map<String, dynamic>?;
    if (!isMap) return ValidationResult.error("$propertyName.runtimeType == ${this.nullable ? "Map<String, dynamic>?" : "Map<String, dynamic>"} ");
    if (this.nullable == false && value == null) return ValidationResult.error("$propertyName != null");
    final map = value as Map<String, dynamic>;
    ValidationResult? result;
    for (final key in this.properties.keys) {
      final property = this.properties[key]!;
      result = property.validate("$propertyName.$key", map[key]);
      if (!result.passed) break;
    }
    result ??= ValidationResult.passed();
    return result;
  }
}

class EnumSchema extends ObjectSchema {
  final ObjectSchema itemSchema;
  final List<Object> values;
  EnumSchema(bool nullable, this.itemSchema, this.values) : super(DataType.enumType, nullable) {
    values.forEach((element) {
      assert(itemSchema.validate("enum-schema-constructor", element).passed);
    });
  }
  @override
  ValidationResult validate(String propertyName, Object? value) {
    return values.any((element) => element == value) ? ValidationResult.passed() : ValidationResult.error("(${propertyName}/* valid values are: ${this.values}*/).shouldContain($value)");
  }
}

