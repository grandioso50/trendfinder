package com.highlow.Controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingPathVariableException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import com.highlow.Entity.FailResponse;
import com.highlow.Entity.SuccessResponse;
import com.highlow.Enum.ErrorCode;
import com.highlow.Enum.ErrorMessage;

/**
 * コントローラが継承するベースクラス
 * 例外をキャッチし、エラーレスポンスエンティティを作成する
 * 
 * @author Kiyoshi Hirao
 * @date 2017/10/17
 *
 */
@ControllerAdvice
public class ApiController {
	private FailResponse failRes = new FailResponse();
	protected SuccessResponse OKRes = new SuccessResponse();
	
	@ExceptionHandler(MethodArgumentNotValidException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	private FailResponse handleException(MethodArgumentNotValidException e) {
		setValidationErrorResponse(e.getBindingResult());
		return failRes;
	}
	
	
	@ExceptionHandler(MissingServletRequestParameterException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	private FailResponse handleException(MissingServletRequestParameterException e) {
		List<HashMap<String, Object>> errorlist = new ArrayList<HashMap<String, Object>>();
		failRes.getError().setCode(ErrorCode.VALIDATION_FAIL.getValue());
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", e.getMessage());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		return failRes;
	}
	
	@ExceptionHandler(MissingPathVariableException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	private FailResponse handleException(MissingPathVariableException e) {
		failRes.getError().setCode(ErrorCode.VALIDATION_FAIL.getValue());
		List<HashMap<String, Object>> errorlist = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", e.getMessage());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		return failRes;
	}
	
	
	
	@ExceptionHandler(BindException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	private FailResponse handleException(BindException e) {
		setValidationErrorResponse(e.getBindingResult());
		return failRes;
	}
	
	@ExceptionHandler(Exception.class)
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	private FailResponse handleException(Exception e) {
		List<HashMap<String, Object>> errorlist = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", e.getMessage());
		map.put("cause", e.getCause());
		map.put("stackTrace", e.getStackTrace());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		e.printStackTrace();
		return failRes;
	}
	
	private void setValidationErrorResponse(BindingResult result) {
		List<HashMap<String, Object>> errorlist = new ArrayList<HashMap<String, Object>>();
		failRes.getError().setCode(ErrorCode.VALIDATION_FAIL.getValue());
		FieldError fielderr;
		List<ObjectError> errors = result.getAllErrors();
		for (ObjectError err: errors) {
			fielderr = (FieldError) err;
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("message", fielderr.getDefaultMessage());
			map.put("field", fielderr.getField());
			map.put("rejectedValue", fielderr.getRejectedValue());
			errorlist.add(map);
		}
		failRes.getError().setDetail(errorlist);
	}
	
	@ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
	@ExceptionHandler({HttpRequestMethodNotSupportedException.class})
	@ResponseBody
	public FailResponse handleMethodNotAllowed() {
		List<HashMap<String, Object>>errorlist = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", ErrorMessage.METHOD_NOT_ALLOWED.getValue());
		failRes.getError().setCode(ErrorCode.METHOD_NOT_ALLOWED.getValue());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		return failRes;
	}

	
	@ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
	@ExceptionHandler({HttpMediaTypeNotAcceptableException.class})
	@ResponseBody
	public FailResponse handleNotAcceptable() {
		List<HashMap<String, Object>>errorlist = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", ErrorMessage.NOT_ACCEPTABLE.getValue());
		failRes.getError().setCode(ErrorCode.NOT_ACCEPTABLE.getValue());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		return failRes;
	}
	
	@ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
	@ExceptionHandler({HttpMediaTypeNotSupportedException.class})
	@ResponseBody
	public FailResponse handleNotSupported() {
		List<HashMap<String, Object>>errorlist = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("message", ErrorMessage.NOT_ACCEPTABLE.getValue());
		failRes.getError().setCode(ErrorCode.NOT_ACCEPTABLE.getValue());
		errorlist.add(map);
		failRes.getError().setDetail(errorlist);
		return failRes;
	}
}
