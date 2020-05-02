package com.highlow.Entity;

public class FailResponse {
	private boolean result = false;
	private ErrorResponse error = new ErrorResponse();
	public boolean isResult() {
		return result;
	}
	public void setResult(boolean result) {
		this.result = result;
	}
	public ErrorResponse getError() {
		return error;
	}
	public void setError(ErrorResponse error) {
		this.error = error;
	}
}