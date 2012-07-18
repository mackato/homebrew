require 'formula'

class AtlassianJira < Formula
  url 'http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-5.1.tar.gz'
  homepage 'http://www.atlassian.com/software/jira/overview'
  md5 '59de61e6da2647fc49f5b2a2e0a0ba93'
  
  keg_only "This is binary distribution."
  skip_clean :all

  JIRA_HOME = "/usr/local/var/jira-home"

  def install
    system "mkdir #{JIRA_HOME}" unless File.exist?(JIRA_HOME)
    prefix.install Dir['*']
    system "echo 'jira.home = #{JIRA_HOME}' > #{prefix}/atlassian-jira/WEB-INF/classes/jira-application.properties"
    (prefix+"com.atlassian.jira.plist").write startup_plist
    (prefix+"com.atlassian.jira.plist").chmod 0644
  end
  
  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.atlassian.jira</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{bin}/catalina.sh</string>
    <string>run</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>ServiceDescription</key>
  <string>JIRA autoloaded as a service</string>
  <key>UserName</key>
  <string>#{`whoami`.chomp}</string>
</dict>
</plist>
EOS
  end
  
  def caveats; <<-EOS.undent
    Start JIRA
      #{prefix}/bin/startup.sh
    
    Run the Setup Wizard
      see http://localhost:8080/

    You can start jira automatically on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{prefix}/com.atlassian.jira.plist ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/com.atlassian.jira.plist      
    EOS
  end
end
