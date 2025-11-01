abstract class BaseModel {
  int? id;
  
  BaseModel({this.id});
  
  Map<String, dynamic> toJson();
  
  BaseModel.fromJson(Map<String, dynamic> json) : id = json['id'] as int?;
}