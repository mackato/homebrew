require 'formula'

class AtlassianConfluence < Formula
  url 'http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-4.2.8.tar.gz'
  homepage 'http://www.atlassian.com/software/confluence/overview'
  md5 'dbd3a0d182f3d3a552743b025e17aef5'

  keg_only "This is binary distribution."
  skip_clean :all
  
  CONFLUENCE_HOME = "/usr/local/var/confluence-home"

  def install
    system "mkdir #{CONFLUENCE_HOME}" unless File.exist?(CONFLUENCE_HOME)
    prefix.install Dir['*']
    system "echo 'confluence.home=#{CONFLUENCE_HOME}' > #{prefix}/confluence/WEB-INF/classes/confluence-init.properties"
    (bin + "launchd_wrapper.sh").write launchd_wrapper
    (bin + "launchd_wrapper.sh").chmod 0755
    (prefix + "com.atlassian.confluence.plist").write startup_plist
    (prefix + "com.atlassian.confluence.plist").chmod 0644
  end
  
    def launchd_wrapper
      return <<-EOS
#!/bin/bash
 
function shutdown()
{
        date
        echo "Shutting down Confluence"
        $CATALINA_HOME/bin/catalina.sh stop
}
 
date
echo "Starting Confluence"
export CATALINA_PID=/tmp/$$
 
# Uncomment to increase Tomcat's maximum heap allocation
# export JAVA_OPTS=-Xmx512M $JAVA_OPTS
 
. $CATALINA_HOME/bin/catalina.sh start
 
# Allow any signal which would kill a process to stop Tomcat
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
    <string>#{prefix}</string>
    <key>JAVA_HOME</key>
    <string>/Library/Java/Home</string>
  </dict>
  <key>Label</key>
  <string>com.atlassian.confluence</string>
  <key>OnDemand</key>
  <false/>
  <key>ProgramArguments</key>
  <array>
    <string>#{bin}/launchd_wrapper.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>ServiceDescription</key>
  <string>Confluence</string>
  <key>StandardErrorPath</key>
  <string>#{prefix}/logs/launchd.stderr</string>
  <key>StandardOutPath</key>
  <string>#{prefix}/launchd.stdout</string>
  <key>UserName</key>
  <string>#{`whoami`.chomp}</string>
</dict>
</plist>
EOS
  end

  def caveats; <<-EOS.undent
    Setup Database:
      see http://confluence.atlassian.com/display/DOC/Database+Setup+Guides
        
    Start Confluence and Confluence Setup Wizard
      #{bin}/start-confluence.sh
      see http://localhost:8090/

    You can start crowd automatically on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{prefix}/com.atlassian.confluence.plist ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/com.atlassian.confluence.plist
    EOS
  end
end
