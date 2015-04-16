--
-- Tabellstruktur for tabell `netlist`
--

CREATE TABLE IF NOT EXISTS `netlist` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `network` varchar(16) NOT NULL,
  `subnet` varchar(16) NOT NULL,
  `vlan` int(12) DEFAULT NULL,
  `coreswitch` int(12) NOT NULL,
  `dhcp` int(1) DEFAULT '0',
  `dhcp_reserved` varchar(12) DEFAULT '0',
  `last_dhcp_request` int(12) DEFAULT '0',
  `desc` varchar(64) DEFAULT NULL,
  `in_use` int(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Tabellstruktur for tabell `switches`
--

CREATE TABLE IF NOT EXISTS `switches` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `distro_id` int(12) DEFAULT NULL,
  `distro_port` varchar(64) DEFAULT NULL,
  `model` varchar(45) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `net_id` int(12) DEFAULT NULL,
  `configured` int(1) DEFAULT '0',
  `placement` varchar(12) DEFAULT NULL,
  `alive` int(1) DEFAULT '0',
  `last_update` int(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Tabellstruktur for tabell `coreswitches`
--

CREATE TABLE IF NOT EXISTS `coreswitches` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `model` varchar(45) NOT NULL,
  `ip` varchar(42) DEFAULT NULL,
  `configured` int(1) DEFAULT '0',
  `placement` varchar(12) DEFAULT NULL,
  `de_ports` varchar(32) DEFAULT '0',
  `alive` int(1) DEFAULT '0',
  `last_update` int(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Tabellstruktur for tabell `link_networks`
--

CREATE TABLE IF NOT EXISTS `link_networks` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `core_1` int(12) NOT NULL,
  `core_2` int(12) NOT NULL,
  `configured` int(1) DEFAULT '0',
  `ip_range` varchar(32) DEFAULT '0.0.0.0/30',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
