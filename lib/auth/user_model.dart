class UserModel {
	String fullName;
	String userEmail;
	String asteriskUsername;
	String asteriskPassword;
	String organizationName;
	String domain;
	String role;
	String loginCounter;
	int iat;
	int exp;

	UserModel(
			this.fullName,
				this.userEmail,
				this.asteriskUsername,
				this.asteriskPassword,
				this.organizationName,
				this.domain,
				this.role,
				this.loginCounter,
				this.iat,
				this.exp);

	UserModel.fromMapObject(Map<String, dynamic> json) {
		fullName = json['FullName'];
		userEmail = json['UserEmail'];
		asteriskUsername = json['asteriskUsername'];
		asteriskPassword = json['asteriskPassword'];
		organizationName = json['organizationName'];
		domain = json['domain'];
		role = json['role'];
		loginCounter = json['loginCounter'];
		iat = json['iat'];
		exp = json['exp'];
	}

	Map<String, dynamic> toMap() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['FullName'] = this.fullName;
		data['UserEmail'] = this.userEmail;
		data['asteriskUsername'] = this.asteriskUsername;
		data['asteriskPassword'] = this.asteriskPassword;
		data['organizationName'] = this.organizationName;
		data['domain'] = this.domain;
		data['role'] = this.role;
		data['loginCounter'] = this.loginCounter;
		data['iat'] = this.iat;
		data['exp'] = this.exp;
		return data;
	}
}