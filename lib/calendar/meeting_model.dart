import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

@JsonSerializable()
class MeetingModel {
	String id;
	String title;
	String from;
	String attendees;
	String description;
	String start;
	String end;
	String color;
	String background;
	String recurrenceRule;
	String meetingLink;

	MeetingModel(
			{this.id,
				this.title,
				this.from,
				this.attendees,
				this.description,
				this.start,
				this.end,
				this.color,
				this.background,
				this.recurrenceRule,
				this.meetingLink});

	MeetingModel.fromJson(Map<String, dynamic> json) {
		id = json['Id'];
		title = json['Title'];
		from = json['From'];
		attendees = json['Attendees'];
		description = json['Description'];
		start = json['Start'];
		end = json['End'];
		color = json['color'];
		background = json['background'];
		recurrenceRule = json['recurrenceRule'];
		meetingLink = json['MeetingLink'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['Id'] = this.id;
		data['Title'] = this.title;
		data['From'] = this.from;
		data['Attendees'] = this.attendees;
		data['Description'] = this.description;
		data['Start'] = this.start;
		data['End'] = this.end;
		data['color'] = this.color;
		data['background'] = this.background;
		data['recurrenceRule'] = this.recurrenceRule;
		data['MeetingLink'] = this.meetingLink;
		return data;
	}
}