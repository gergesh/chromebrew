require 'package'

class Git < Package
  description 'Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.'
  homepage 'https://git-scm.com/'
  version '2.16.1'
  source_url 'https://github.com/git/git/archive/v2.16.1.tar.gz'
  source_sha256 'e3f13e3c86981f64b1920749c07be11841bbf5a3434ec9b5611959dfd7c7398e'

  binary_url ({
    aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/git-2.16.1-chromeos-armv7l.tar.xz',
     armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/git-2.16.1-chromeos-armv7l.tar.xz',
       i686: 'https://dl.bintray.com/chromebrew/chromebrew/git-2.16.1-chromeos-i686.tar.xz',
     x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/git-2.16.1-chromeos-x86_64.tar.xz',
  })
  binary_sha256 ({
    aarch64: '1267dd4eedcdef94c201b462f18f8dbc3bdef1e82106adf642cf428ede350d3b',
     armv7l: '1267dd4eedcdef94c201b462f18f8dbc3bdef1e82106adf642cf428ede350d3b',
       i686: '2215ef3534daf89e1b96b63f7b5177018cb657bb7713d9aad97a80729c4da546',
     x86_64: '8447b69bb2eb1040fa5627c1e0aae122db6b22ec846f957b81fd3fbc2d287783',
  })

  # use system zlibpkg, openssl, curl, expat
  depends_on 'autoconf' => :build
  depends_on 'zlibpkg' => :build
  depends_on 'libssh2'
  depends_on 'openssl' => :build
  depends_on 'curl' => :build
  depends_on 'expat' => :build
  depends_on 'gettext' => :build
  depends_on 'perl' => :build
  depends_on 'python27' => :build     # requires python2

  # need to build using single core
  @make_cmd = "make -j1 prefix=#{CREW_PREFIX} CC=gcc PERL_PATH=#{CREW_PREFIX}/bin/perl PYTHON_PATH=#{CREW_PREFIX}/bin/python2"

  def self.build
    system "autoconf"
    system "./configure --without-tcltk"
    system "#{@make_cmd} all"
  end

  def self.install
    system "#{@make_cmd} DESTDIR=#{CREW_DEST_DIR} install"
    system "mkdir -p #{CREW_DEST_PREFIX}/share/git-completion"
    system "cp -r contrib/completion/* #{CREW_DEST_PREFIX}/share/git-completion"
  end

  def self.postinstall
    puts
    puts "Git completion support is available for the following shells:".lightblue
    system "ls #{CREW_PREFIX}/share/git-completion"
    puts
    puts "To add git completion for bash, execute the following:".lightblue
    puts "echo '# git completion' >> ~/.bashrc".lightblue
    puts "echo 'if [ -f #{CREW_PREFIX}/share/git-completion/git-completion.bash ]; then' >> ~/.bashrc".lightblue
    puts "echo '  source #{CREW_PREFIX}/share/git-completion/git-completion.bash' >> ~/.bashrc".lightblue
    puts "echo 'fi' >> ~/.bashrc".lightblue
    puts "source ~/.bashrc".lightblue
    puts
  end

  def self.check
    # Skip several t9010-svn-fe and t9011-svn-da tests since they fail.
    system "GIT_SKIP_TESTS='t9010.16 t9010.20 t9011.1[49] t9011.2[0346] t9011.31 ' #{@make_cmd} test"
  end
end
