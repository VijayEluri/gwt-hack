package com.bizo.gwthack.shared.messages;

import java.util.ArrayList;

import org.gwtmpv.GenDispatch;
import org.gwtmpv.In;
import org.gwtmpv.Out;

import com.bizo.gwthack.shared.model.ClientDto;

@GenDispatch
public class SaveClientSpec {
  @In(1)
  ClientDto client;
  @Out(1)
  boolean success;
  @Out(2)
  ArrayList<String> messages;
}