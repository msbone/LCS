--
-- Tabellstruktur for tabell `netlist`
--

CREATE TABLE IF NOT EXISTS `netlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `network` varchar(45) NOT NULL,
  `subnet` varchar(45) NOT NULL,
  `dhcp` int(1) DEFAULT '0',
  `dhcp_reserved` varchar(45) DEFAULT '0',
  `dhcp_used` int(12) DEFAULT '0',
  `desc` varchar(100) DEFAULT NULL,
  `de` int(1) DEFAULT '0',
  `wifi` int(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Tabellstruktur for tabell `switches`
--

CREATE TABLE IF NOT EXISTS `switches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `core` varchar(45) DEFAULT NULL,
  `core_port` varchar(45) DEFAULT NULL,
  `model` varchar(45) NOT NULL,
  `net_id` int(11) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `configured` int(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=160 ;
