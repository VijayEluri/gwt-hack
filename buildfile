
require 'buildr/ivy_extension'
require 'gwt.rb'

# Buildr.application.options.trace_categories = [:ant]

THIS_VERSION = ENV['version'] || 'SNAPSHOT'

# to resolve the ${version} in the ivy.xml
Java.java.lang.System.setProperty("version", THIS_VERSION)

# just for buildr to get trax, then everything else is ivy
repositories.remote << 'http://www.ibiblio.org/maven2'

define 'gwt-hack' do
  ivy.compile_conf(['compile', 'provided']).test_conf('test').package_conf('compile')

  project.group = 'com.bizo'
  project.version = THIS_VERSION
  project.compile.using :target => '1.6', :source => '1.6', :other => ['-XprintRounds']
  project.resources.from(_('src/main/java')).exclude('*.java')

  package(:war)

  compile.with '/home/stephen/other/lombok/dist/lombok.jar'

  compile.from _('src/main/super')

  resources = FileList[_('src/main/java/com/bizo/gwthack/client/resources/**/*')]
  views     = FileList[_('src/main/java/com/bizo/gwthack/client/views/**/*')]
  generated_java = file(_('target/generated/java') => (views + resources)) do |dir|
    mkdir_p dir.to_s
    touch dir.to_s
    task('gwt-mpv:generate').invoke
  end

  compile.from generated_java

  task :gwt => [:compiledeps, 'gwt-mpv:generate', gwt('com.bizo.gwthack.GwtHack', {
    :max_memory => '512m',
    :style => 'OBF',
    :jvmargs => ['-Djava.awt.headless=true', '-javaagent:/home/stephen/other/lombok/dist/lombok.jar=ECJ'],
    :classpath => ['/home/stephen/other/lombok/dist/lombok.jar']
  })]

  task 'gwt-mpv:generate' => :compiledeps do
    puts "Generating gwt-mpv output..."
    Buildr.ant('gwt-mpv:generate') do |ant|
      pathid = "#{project.name}-gwt-mpv-classpath"
      ant.path :id => pathid do
        project.compile.dependencies.each do |path|
          ant.pathelement :location => path
        end
      end
      ant.java :fork => true, :failonerror => true, :classname => 'org.gwtmpv.generators.Generator' do
        ant.classpath :refid => pathid
        ant.arg :value => '--inputDirectory'
        ant.arg :value => 'src/main/java'
        ant.arg :value => '--outputDirectory'
        ant.arg :value => 'target/generated/java'
        ant.arg :value => '--viewsPackageName'
        ant.arg :value => 'com.bizo.gwthack.client.views'
        ant.arg :value => '--resourcesPackageName'
        ant.arg :value => 'com.bizo.gwthack.client.resources'
      end
    end
  end
end

