package com.highlow.Controller;

import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.highlow.Entity.BidRequest;
import com.highlow.Entity.SuccessResponse;
import com.highlow.Service.BidService;

/**
 * UAVコマンド送信コントローラ
 * @author Kiyoshi Hirao
 * @date 2017/10/17
 *
 */
@Controller
@RestController
@RequestMapping("/bid")
public class BidController extends ApiController {
    @Autowired
    private BidService service;
    
    @RequestMapping(method=RequestMethod.POST)
    @ResponseStatus(HttpStatus.OK)
    public SuccessResponse executeCommand(HttpServletRequest request, 
    		@RequestBody @Valid BidRequest bdrequest) throws Exception {
        service.execute(bdrequest);
    	return OKRes;
    }

}
