package com.learning;

import static org.junit.Assert.*;

import org.junit.Test;

public class CalculatorTest {

	@Test public void testAdd() {
        Calculator calc = new Calculator();
        
        assertEquals(7,calc.add(3,4));
    }
	//test cases
	//test case
	@Test public void testmul() {
         Calculator calc = new Calculator();
        
        assertEquals(12,calc.mul(3,4));
    }
}
