require 'formula'

class Fisheye < Formula
  url 'http://www.atlassian.com/software/fisheye/downloads/binary/fisheye-2.7.10.zip'
  homepage ''
  md5 'b048b71543c3549494e17a89cc32bdb2'

  keg_only "This is binary distribution."
  skip_clean :all
  
  FISHEYE_INST = "/usr/local/var/fisheye-inst"

  def install
    system "mkdir #{FISHEYE_INST}" unless File.exist?(FISHEYE_INST)
    prefix.install Dir['*']
    system "cp #{prefix}/config.xml #{FISHEYE_INST}/config.xml"
    (prefix + "com.atlassian.fisheye.plist").write startup_plist
    (prefix + "com.atlassian.fisheye.plist").chmod 0644
  end
  
  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.atlassian.fisheye</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{bin}/run.sh</string>
  </array>
    <key>OnDemand</key>
    <false/>
    <key>RunAtLoad</key>
    <true/>
  <key>StandardOutPath</key>
  <string>#{prefix}/var/log/fisheye.out</string>
  <key>StandardErrorPath</key>
  <string>#{prefix}/var/log/fisheye.error</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>FISHEYE_INST</key>
    <string>#{FISHEYE_INST}</string>
    <key>FISHEYE_OPTS</key>
    <string>-Xms512m -Xmx1024m -XX:MaxPermSize=128m -Dfile.encoding=UTF-8</string>
  </dict> 
</dict>
</plist>
EOS
  end
  
  def caveats; <<-EOS.undent
    Start Fisheye
      #{bin}/run.sh
      see http://localhost:8060/

    You can start fisheye automatically on login with:
      mkdir -p ~/Library/LaunchAgents
      cp #{prefix}/com.atlassian.fisheye.plist ~/Library/LaunchAgents/
      launchctl load -w ~/Library/LaunchAgents/com.atlassian.fisheye.plist
    EOS
  end
end
