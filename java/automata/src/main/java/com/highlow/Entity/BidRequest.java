package com.highlow.Entity;

import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BidRequest {
	@NotNull
	private String pair;
	@NotNull
	private Boolean isHigh;    
}
