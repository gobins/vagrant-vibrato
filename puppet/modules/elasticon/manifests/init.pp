class elasticon{
  require docker

  docker::image { 'elasticsearch':
    image_tag => 'latest'
  } ->

  docker::run { 'run-elasticsearch':
    image   => 'elasticsearch',
    ports   => ['9200:9200', '9300:9300'],
    volumes => ['/vagrant:/elasticsearch/config/'],
  } ->
  # exec {'start-es-container':
  #   command    => "docker run -d -p 9200:9200 -p 9300:9300 -v /vagrant:/data elasticsearch /elasticsearch/bin/elasticsearch -Des.config=/data/elasticsearch.yml",
  #   path       => '/usr/bin',
  # } ->

  exec {'wait-for-es':
    command    => "curl -XGET http://localhost:9200/",
    tries      => "10",
    try_sleep  => 5,
    path       => '/usr/bin',
    before     => Exec['run-csv-load']
  } ->

  wget::fetch { "download-ict-report":
    source      => "http://data.nsw.gov.au/data/dataset/cf9d3c60-f07c-47ef-8fe3-ae94a308bcf2/resource/7cef0d5c-d38d-4074-b9dd-3f27ef7ce9f6/download/ICT-Survey-Data-2014-15-CSV.zip",
    destination => '/tmp/',
    timeout     => 0,
    verbose     => false,
  }

  package { 'unzip':
    ensure => present,
  } ->

  exec { 'unzip':
    command     => 'unzip ICT-Survey-Data-2014-15-CSV.zip -d /tmp',
    cwd         => '/tmp',
    path        => '/usr/bin',
    require     => Wget::Fetch["download-ict-report"],
    creates     => "/tmp/ICT Survey Data 2014-15 CSV/Figure 1.csv",
    returns     => 0,
  }

  file { "/tmp/load_csv_data.py":
    mode    => "0744",
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/elasticon/load_csv_data.py',
    require => Exec['unzip']
  }

  exec { 'clear-index':
    command  => "curl -XDELETE http://localhost:9200/ict",
    path     => '/usr/bin',
    require  => Exec['wait-for-es']
  } ->

  exec { 'run-csv-load':
    command     => 'python /tmp/load_csv_data.py --file /tmp/ICT\ Survey\ Data\ 2014-15\ CSV/Figure\ 10.csv',
    cwd         => '/tmp',
    path        => '/usr/bin',
    require     => File["/tmp/load_csv_data.py"],
  }->

  service { 'firewalld':
    enable => false,
    ensure => stopped,
  }

}
