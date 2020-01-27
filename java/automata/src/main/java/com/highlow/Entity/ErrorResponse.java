package com.highlow.Entity;

public class ErrorResponse {
	private Integer code = 5000;
	private Object detail;
	public Object getDetail() {
		return detail;
	}
	public void setDetail(Object detail) {
		this.detail = detail;
	}
	public Integer getCode() {
		return code;
	}
	public void setCode(Integer code) {
		this.code = code;
	}

}