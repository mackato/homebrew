require 'formula'

class AtlassianCrowd < Formula
  url 'http://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.4.0.tar.gz'
  homepage ''
  md5 'a8d7dea41509a295ad389b4ee5ffa56a'

  keg_only "This is binary distribution."
  skip_clean :all
  
  CROWD_HOME = "/usr/local/var/crowd-home"

  def install
    system "mkdir #{CROWD_HOME}" unless File.exist?(CROWD_HOME)
    prefix.install Dir['*']
    system "echo 'crowd.home = #{CROWD_HOME}' > #{prefix}/crowd-webapp/WEB-INF/classes/crowd-init.properties"
    (bin + "launchd_wrapper.sh").write launchd_wrapper
    (bin + "launchd_wrapper.sh").chmod 0755
    (prefix + "com.atlassian.crowd.plist").write startup_plist
    (prefix + "com.atlassian.crowd.plist").chmod 0644
  end
  
  def launchd_wrapper
    return <<-EOS
#!/bin/bash

function shutdown()
{
        date
        echo "Shutting down Crowd"
        $CATALINA_HOME/bin/catalina.sh stop
}
 
date
echo "Starting Crowd"
export CATALINA_PID=/tmp/$$
 
# Uncomment to increase Tomcat's maximum heap allocation
# export JAVA_OPTS=-Xmx512M $JAVA_OPTS
 
. $CATALINA_HOME/bin/catalina.sh start
 
# Allow any signal that would kill a process to stop Tomcat
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP
 
echo "Waiting for `cat $CATALINA_PID`"
wait `cat $CATALINA_PID`
EOS
  end
  
  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" ">
<plist version="1.0">
<dict>
  <key>Disabled</key>
  <false/>
  <key>EnvironmentVariables</key>
  <dict>
    <key>CATALINA_HOME</key>
    <string>#{prefix}/apache-tomcat</string>
    <key>JAVA_HOME</key>
    <string>/Library/Java/Home</string>
  </dict>
  <key>Label</key>
  <string>com.atlassian.crowd</string>
  <key>OnDemand</key>
  <false/>
  <key>ProgramArguments</key>
  <array>
    <string>#{prefix}/bin/launchd_wrapper.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>ServiceDescription</key>
  <string>Crowd</string>
  <key>StandardErrorPath</key>
  <string>#{prefix}/apache-tomcat/logs/launchd.stderr</string>
  <key>StandardOutPath</key>
  <string>#{prefix}/apache-tomcat/logs/launchd.stdout</string>
  <key>UserName</key>
  <string>#{`whoami`.chomp}</string>
</dict>
</plist>
EOS
  end

  def caveats; <<-EOS.undent
    Optional Prepare your Database:
      Connecting Crowd to a Database:
        see http://confluence.atlassian.com/display/CROWD/Connecting+Crowd+to+a+Database
      Connecting CrowdID to a Database
        see http://confluence.atlassian.com/display/CROWD/Connecting+CrowdID+to+a+Database
        
    Start Crowd and Complete the Setup Wizard
      #{prefix}/start_crowd.sh
      see http://localhost:8095/crowd

    You can start crowd automatically on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{prefix}/com.atlassian.crowd.plist ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/com.atlassian.crowd.plist
    EOS
  end
end
