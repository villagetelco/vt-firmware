        <div class="tab-pane" id="voice">
          <div class="col-md-offset-2 col-md-8 col-md-offset-2">
            <form class="form-horizontal" id="voiceForm" method="POST" action="/cgi-bin/voice_save.sh">
              <fieldset class="asterisk-adv">
                <legend>Asterisk Configuration</legend>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">Enable Asterisk</label>
                      <div class="controls">
                        <div class="switch" data-on="primary" data-off="info">
                          <input type="checkbox" name="ENABLE_AST" id="enable_ast" <%= $ENABLE_AST %> > 
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group">             
                      <label class="control-label">SIP Status</label>
                      <div class="col-md-4">
                        <p class="form-control-static"><%=  $REG_STATUS $REG_ACCT %></p>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="USER">User Name</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="USER" id="user" value="<%= $USERNAME %>" > 
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="SECRET">Password</label>
                      <div class="controls">
                        <input  type="text" class="form-control" name="SECRET" id="secret" value="<%= $SECRET %>" >
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">                  
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="HOST">SIP Host</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="HOST" id="host" value="<%= $HOST %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">Dialout Code</label>
                      <div class="controls">
                        <SELECT class="form-control" name="DIALOUT" id="dialout">
                          <option selected="<%= $DIALOUT %>"><%= $DIALOUT %></option>
                          <option value="#"> # </option>
                          <option value="9"> 9 </option>
                          <option value="0"> 0 </option>
                        </SELECT>
                      </div>
                    </div>
                  </div>      
                </div>
                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="REGHOST">SIP Registrar</label> 
                      <div class="controls">
                        <input type="text" class="form-control" name="REGHOST" id="reghost" value="<%= $REGHOST %>" > 
                      </div>
                    </div>
                  </div>

                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">Softphone Support</label>
                      <div class="controls">
                        <SELECT class="form-control" name="SOFTPH" id="softph">
                          <option selected="<%= $SOFTPH %>"><%= $SOFTPH %></option>
                          <option value="OFF"> OFF </option>
                          <option value="CLIENT"> CLIENT </option>
                          <option value="MASTER"> MASTER </option>
                        </SELECT>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row adv_ui hide">
                  <div class="col-md-2">
                    <div class="form-group">             
                      <label class="control-label">Codec1</label>
                      <div class="controls">
                        <SELECT class="form-control" name="CODEC1" id="codec1">
                          <option selected="<%= $CODEC1 %>"><%= $CODEC1 %></option>
                          <option value="gsm">gsm</option>
                          <option value="ulaw">ulaw</option>
                          <option value="alaw">alaw</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>

                  <div class="col-md-2">
                    <div class="form-group">             
                      <label class="control-label">Codec2</label>
                      <div class="controls">
                        <SELECT class="form-control" name="CODEC2" id="codec2">
                          <option selected="<%= $CODEC2 %>"><%= $CODEC2 %></option>
                          <option value="gsm">gsm</option>
                          <option value="ulaw">ulaw</option>
                          <option value="alaw">alaw</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>                        
                
                  <div class="col-md-2">
                    <div class="form-group">             
                      <label class="control-label">Codec3</label>
                      <div class="controls">
                          <SELECT class="form-control" name="CODEC3" id="codec3">
                            <option selected="<%= $CODEC3 %>"><%= $CODEC3 %></option>
                            <option value="gsm">gsm</option>
                            <option value="ulaw">ulaw</option>
                            <option value="alaw">alaw</option>
                          </SELECT>
                      </div>
                    </div>
                  </div>     

                </div> 
                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">SIP Enable</label>
                      <div class="controls">
                        <div class="switch">
                          <input  type="checkbox" name="ENABLE" id="enable" value="checked" <%= $ENABLE %> > 
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">SIP Register</label>
                      <div class="controls">
                        <div class="switch">
                          <input  type="checkbox" name="REGISTER" id="register" value="checked" <%= $REGISTER %> > 
                        </div>
                      </div>
                    </div>
                  </div>                        
                </div>
                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">Asterisk NAT</label>
                      <div class="controls">
                        <div class="switch"  data-on-label="Enable" data-off-label="Disable" >
                          <input  type="checkbox" name="ENABLENAT" id="enablenat" value="checked" $ENABLENAT > 
                        </div>
                      </div>
                    </div>
                  </div>   
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="EXTERNIP">NAT External IP</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="EXTERNIP" id="externip" value="<%= $EXTERNIP %>" >
                      </div>
                    </div>
                  </div>
                </div>
              </fieldset>

              <div class="row">
                <div id="vsuccess"></div>   
                <div class="col-md-offset-2 col-md-6">
                  <div class="form-actions">
                    <INPUT TYPE="SUBMIT" class="btn btn-default" name="BUTTON" value="Save">
                    <INPUT TYPE="SUBMIT" class="btn" name="BUTTON" value="Restart Asterisk" >
                    <INPUT TYPE="SUBMIT" class="btn" name="BUTTON" value="Reboot" >
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>