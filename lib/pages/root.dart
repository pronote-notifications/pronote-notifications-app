import 'package:flutter/material.dart';
import 'package:pronote_notifications/pages/login.dart';
import 'package:pronote_notifications/services/authentication.dart';
import 'package:pronote_notifications/pages/home.dart';

enum AuthStatus {
	NOT_DETERMINED,
	NOT_LOGGED_IN,
	LOGGED_IN,
}

class RootPage extends StatefulWidget {
	RootPage({this.auth});

	final BaseAuth auth;

	@override
	State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
	AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
	UserData _userData;

	@override
	void initState() {
		super.initState();

		widget.auth.isLogged().then((isLogged) {
			if (!isLogged) {
				setState(() {
					authStatus = AuthStatus.NOT_LOGGED_IN;
				});
			} else {
				widget.auth.login().then((userData) {
					setState(() {
						_userData = userData;
						authStatus = AuthStatus.LOGGED_IN;
					});
				}).catchError((err) => {
					setState(() {
						authStatus = AuthStatus.NOT_LOGGED_IN;
					})
				});
			}
		});
  	}

	void loginCallback(UserData userData) {
			setState(() {
				_userData = userData;
				authStatus = AuthStatus.LOGGED_IN;
			});
	}

	void logoutCallback() {
		setState(() {
			authStatus = AuthStatus.NOT_LOGGED_IN;
			_userData = null;
		});
	}

	Widget buildWaitingScreen() {
		return Scaffold(
			body: Container(
				alignment: Alignment.center,
				child: CircularProgressIndicator(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		switch (authStatus) {
		case AuthStatus.NOT_DETERMINED:
			return buildWaitingScreen();
			break;
		case AuthStatus.NOT_LOGGED_IN:
			return new LoginPage(
				auth: widget.auth,
				loginCallback: loginCallback,
			);
			break;
		case AuthStatus.LOGGED_IN:
			if (_userData != null) {
				return new HomePage(
					userData: _userData,
					auth: widget.auth,
					logoutCallback: logoutCallback,
				);
			} else return buildWaitingScreen();
			break;
		default:
			return buildWaitingScreen();
		}
	}
}