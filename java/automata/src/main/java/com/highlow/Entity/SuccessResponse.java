package com.highlow.Entity;

import lombok.Data;

@Data
public class SuccessResponse {
	private boolean result = true;
	private Object data;
	public boolean isResult() {
		return result;
	}
	public void setResult(boolean result) {
		this.result = result;
	}
	public Object getData() {
		return data;
	}
	public void setData(Object data) {
		this.data = data;
	}
}
