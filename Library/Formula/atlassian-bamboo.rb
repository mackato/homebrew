require 'formula'

class AtlassianBamboo < Formula
  url 'http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-3.4.3-standalone.tgz'
  homepage 'http://www.atlassian.com/software/bamboo'
  md5 '62e7043f959cd497881dbe87113b8725'
  version '3.4.3'

  keg_only "This is binary distribution."
  skip_clean :all
  
  BAMBOO_HOME = "/usr/local/var/bamboo-home"

  def install
    system "mkdir #{BAMBOO_HOME}" unless File.exist?(BAMBOO_HOME)
    prefix.install Dir['*']
    system "echo 'bamboo.home = #{BAMBOO_HOME}' > #{prefix}/webapp/WEB-INF/classes/bamboo-init.properties"
  end
  
  def caveats; <<-EOS.undent
    Start Bamboo
      #{prefix}/wrapper/run-bamboo start
      see http://localhost:8085/
      
      The run-bamboo command accepts the following options:
        console — this starts Bamboo in a console. The logs will scroll to standard out.
        start — this starts Bamboo.
        stop — this stops Bamboo.
        status — this provides the current status of Bamboo.
    EOS
  end
end
