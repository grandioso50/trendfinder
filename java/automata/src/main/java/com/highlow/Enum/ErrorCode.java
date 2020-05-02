package com.highlow.Enum;

public enum ErrorCode {
	VALIDATION_FAIL(4001),
	NULL_DRONE(4002),
	PORT_USING(5001),
	NOT_FOUND(4000),
	METHOD_NOT_ALLOWED(4000),
	NOT_ACCEPTABLE(4000),
	REQUEST_TIMEOUT(4000),
	PAYLOAD_TOO_LARGE(4000);
	
	private final int val;
	private ErrorCode (final int val) {
		this.val = val;
	}
	
	public int getValue() {
		return val;
	}
}
