package com.highlow.Enum;

public enum ErrorMessage {
	NULL_DRONE("The UAV connection with requested port not found."),
	PORT_USING("Requested port is in use."),
	NOT_FOUND("Not Found"),
	METHOD_NOT_ALLOWED("Method not allowed"),
	NOT_ACCEPTABLE("Media type not Acceptable"),
	REQUEST_TIMEOUT("Request Timeout"),
	PAYLOAD_TOO_LARGE("Payload Too Large");
	
	private final String msg;
	private ErrorMessage (final String msg) {
		this.msg = msg;
	}
	
	public String getValue() {
		return msg;
	}
}