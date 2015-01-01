--
-- Tabellstruktur for tabell `netlist`
--

CREATE TABLE IF NOT EXISTS `netlist` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `network` varchar(42) NOT NULL,
  `subnet` varchar(64) NOT NULL,
  `dhcp` int(1) DEFAULT '0',
  `dhcp_reserved` varchar(12) DEFAULT '0',
  `dhcp_used` int(12) DEFAULT '0',
  `desc` varchar(64) DEFAULT NULL,
  `de` int(1) DEFAULT '0',
  `wifi` int(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Tabellstruktur for tabell `switches`
--

CREATE TABLE IF NOT EXISTS `switches` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `core` varchar(45) DEFAULT NULL,
  `core_port` varchar(64) DEFAULT NULL,
  `model` varchar(45) NOT NULL,
  `net_id` int(12) DEFAULT NULL,
  `ip` varchar(42) DEFAULT NULL,
  `configured` int(1) DEFAULT '0',
  `placement` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
