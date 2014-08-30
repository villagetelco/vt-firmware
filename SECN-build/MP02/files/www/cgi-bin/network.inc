        <div class="tab-pane fade in active" id="network">
          <div class="col-md-offset-2 col-md-8 col-md-offset-2">
            <form class="form-horizontal" name="MP-ADV" id="networkForm" method="POST" action="/cgi-bin/net_save.sh">
              <fieldset class="ipnetwork">
                <legend>Network</legend>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label data-toggle="tooltip" data-placement="bottom" title="You can also set the IP address by dialing the extension 2663 on the MP or 2662 to just change the last octet. If you just want to find out what the IP address of the MP is dial 2664" class="control-label" for="BR_IPADDR">IP Address</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="BR_IPADDR" id="br_ipaddr" value="<%= $BR_IPADDR %>">
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">  
                    <div class="form-group">
                      <label data-toggle="tooltip" data-placement="bottom" title="You can also set the gateway IP address by dialing the extension 4823 on the MP" class="control-label" for="BR_GATEWAY">Gateway</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="BR_GATEWAY" id="br_gateway" value="<%= $BR_GATEWAY %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-1" id="gwstatus">
                    <%= $GWSTATUS %>
                  </div>
                </div>

                <div class="row adv_ui hide">
                  <div class="col-md-4">  
                    <div class="form-group">
                      <label class="control-label" for="BR_DNS">DNS</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="BR_DNS" id="br_dns" value="<%= $BR_DNS %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="BR_NETMASK">Netmask</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="BR_NETMASK" id="br_netmask" value="<%= $BR_NETMASK %>" >
                      </div>
                    </div>
                  </div>
                </div>
              </fieldset>

              <fieldset class="wifi">
                <legend> WiFi Access Point</legend>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="ssid">SSID</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="SSID" id="ssid" value="<%= $SSID %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for"password">Password</label>
                      <div class="controls">
                        <input type="password" class="form-control" name="PASSPHRASE" id="passphrase" value="<%= $PASSPHRASE %>" >
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label">Encryption</label>
                      <div class="controls">
                        <SELECT class="form-control" name="ENCRYPTION" id="encryption" >
                          <option selected="<%= $ENCRYPTION %>"><%= $ENCRYPTION %></option>
                          <option value="WPA1">WPA1</option>
                          <option value="WPA2">WPA2</option>
                          <option value="WEP">WEP</option>
                          <option value="NONE">None</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label data-toggle="tooltip" data-placement="bottom" title="You can also set the wireless channel by dialing 2426 on the MP"  class="control-label" for="CHANNEL">Channel</label>
                        <div class="controls">
                          <SELECT class="form-control" name="CHANNEL" id="CHANNEL">
                            <option selected="<%= $CHANNEL %>"><%= $CHANNEL %></option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                            <option value="5">5</option>
                            <option value="6">6</option>
                            <option value="7">7</option>
                            <option value="8">8</option>
                            <option value="9">9</option>
                            <option value="10">10</option>
                            <option value="11">11</option>
                            <option value="12">12</option>
                            <option value="13">13</option>
                          </SELECT>
                        </div>
                    </div>
                  </div>
                  <div class="col-md-2 adv_ui hide">
                    <div class="form-group">
                      <label class="control-label">US/Can</label>
                      <div class="controls">
                        <input class="form-control" type="checkbox" name="USREG_DOMAIN" id="usreg_domain" value="checked" $USREG_DOMAIN >
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="MAXASSOC">AP Connections</label>
                      <div class="controls">
                        <SELECT class="form-control" name="MAXASSOC" id="MAXASSOC">
                        <option selected="<%= $MAXASSOC %>"><%= $MAXASSOC %></option>
                        <option value="0">Disabled</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="5">5</option>
                        <option value="10">10</option>
                        <option value="15">15</option>
                        <option value="20">20</option>
                        <option value="25">25</option>
                        </SELECT>
                      </div>
                   </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="ATH0_TXPOWER"> Tx Power 1-20</label>
                      <div class="controls">
                        <input type="text" class="form-control" placeholder=".col-lg-1" name="ATH0_TXPOWER" id="ath0_txpower" value="<%= $ATH0_TXPOWER %>">
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="RADIOMODE">Wifi Mode</label>
                      <div class="controls">
                        <SELECT class="form-control" name="RADIOMODE" id="radiomode">
                          <option selected="<%= $RADIOMODE %>"><%= $RADIOMODE %></option>
                          <option value="802.11G">802.11G</option>
                          <option value="802.11N-G">802.11N-G</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">                 
                      <label class="control-label" for="CHANBW">Chan BW</label>
                      <div class="controls">
                        <SELECT class="form-control" name="CHANBW" id="chanbw" >
                          <option selected="<%= $CHANBW %>"><%= $CHANBW %></option>
                          <option value="5">5MHz</option>
                          <option value="10">10MHz</option>
                          <option value="20">20MHz</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>
                </div>
              </fieldset>

              <fieldset class="meshwifi adv_ui hide">
                <legend> WiFi Mesh </legend>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="ATH0_IPADDR">IP Address</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="ATH0_IPADDR" id="ath0_ipaddr" value="<%= $ATH0_IPADDR %>">
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="ATH0_NETMASK">Netmask</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="ATH0_NETMASK" id="ath0_netmask" value="<%= $ATH0_NETMASK %>">
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="ATH0_SSID"> SSID </label>
                      <div class="controls">
                        <input type="text" class="form-control" name="ATH0_SSID" id="ath0_ssid" value="<%= $ATH0_SSID %>">
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="ATH0_BSSID"> BSSID </label>
                      <div class="controls">
                        <input type="text" class="form-control" name="ATH0_BSSID" id="ath0_bssid" value="<%= $ATH0_BSSID %>">
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label">Gateway Mode</label>
                      <div class="controls">
                        <SELECT class="form-control" name="MPGW" id="mpgw" />
                          <option selected="<%= $MPGW %>"><%= $MPGW %></option>
                          <option value="OFF">OFF</option>
                          <option value="CLIENT">CLIENT</option>
                          <option value="SERVER">SERVER</option>
                          <option value="SERVER-1Mb">SERVER 1Mb</option>
                          <option value="SERVER-2Mb">SERVER 2Mb</option>
                          <option value="SERVER-5Mb">SERVER 5Mb</option>
                          <option value="SERVER-10Mb">SERVER 10Mb</option>
                        </SELECT>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">             
                      <label class="control-label" for="MESH_ENCR">Encryption</label>
                      <div class="controls">
                        <SELECT class="form-control" name="MESH_ENCR" id="MESH_ENCR" >
                          <option selected="off">OFF</option>
                          <!-- <option selected="<%= $MESH_ENCR %>"><%= $MESH_ENCR %></option>
                          <option value="off">OFF</option>
                          <option value="psk">WPA</option>
                          <option value="psk2">WPA2</option> -->
                        </SELECT>
                      </div>
                    </div>
                  </div>
                </div>
              </fieldset>

              <fieldset class="dhcp adv_ui hide">
                <legend>DHCP Server</legend>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label">DHCP Server</label>
                      <div class="switch controls" data-on-label="Enable" data-off-label="Disable" >
                        <input type="checkbox" class="form-control" name="DHCP_ENABLE" id="dhcp_enable" value="checked" $DHCP_ENABLE > 
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label">Authoritative</label>
                      <div class="switch controls" data-on-label="YES" data-off-label="NO">
                        <input type="checkbox" class="form-control" name="DHCP_AUTH" id="dhcp_auth" value="checked" $DHCP_AUTH > 
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="STARTIP">Starting IP</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="STARTIP" id="startip" value="<%= $STARTIP %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="ENDIP">Ending IP</label>
                      <div class="controls">
                        <input type="text" class="form-control" name="ENDIP" id="endip" value="<%= $ENDIP %>" >
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="OPTION_SUBNET"> Subnet Mask </label>
                      <div class="controls">
                        <input type="text" class="form-control" name="OPTION_SUBNET" id="option_subnet" value="<%= $OPTION_SUBNET %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="OPTION_ROUTER"> Gateway Router </label>
                      <div class="controls">
                        <input type="text" class="form-control" name="OPTION_ROUTER" id="option_router" value="<%= $OPTION_ROUTER %>" >
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="LEASETERM"> Lease Term (secs)</label>
                      <div class="controls">
                        <input type="text" class="form-control" placeholder=".col-lg-2" name="LEASETERM" id="leaseterm" value="<%= $LEASETERM %>" >
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="MAXLEASES"> Max Leases </label>
                      <div class="controls">
                        <input type="text" class="form-control" placeholder=".col-lg-2" name="MAXLEASES" id="maxleases" value="<%= $MAXLEASES %>" >
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row adv_ui hide">
                  <div class="col-md-4">
                    <div class="form-group">
                      <label class="control-label" for="DOMAIN"> Domain </label>
                      <div class="controls">
                        <input type="text" class="form-control" name="DOMAIN" id="domain" value="<%= $DOMAIN %>" >
                      </div>
                    </div>
                  </div>
                </div>
              </fieldset>

              <div class="row">
                <div id="nsuccess"></div>                   
                <div class="col-md-offset-2 col-md-6">
                  <div class="form-actions">
                    <INPUT TYPE="SUBMIT" class="btn btn-default" name="BUTTON" value="Save">
                    <INPUT TYPE="SUBMIT" class="btn adv_ui hide" name="BUTTON" value="Restore Defaults">
                    <INPUT TYPE="SUBMIT" class="btn" name="BUTTON" value="Reboot">
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>