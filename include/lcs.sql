-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Vert: localhost
-- Generert den: 10. Jan, 2016 19:11 PM
-- Tjenerversjon: 5.5.46-0ubuntu0.14.04.2
-- PHP-Versjon: 5.5.9-1ubuntu4.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
--
-- Database: `lcs`
--

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `aps`
--

CREATE TABLE IF NOT EXISTS `aps` (
  `id` varchar(64) NOT NULL,
  `mac` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `alias` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `id_2` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `dhcp_leases`
--

CREATE TABLE IF NOT EXISTS `dhcp_leases` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `time` int(32) NOT NULL,
  `network` int(6) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `mac` varchar(64) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `link_networks`
--

CREATE TABLE IF NOT EXISTS `link_networks` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `port1` int(12) NOT NULL,
  `port2` int(12) NOT NULL,
  `configured` int(1) DEFAULT '0',
  `rendered` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `mac_table`
--

CREATE TABLE IF NOT EXISTS `mac_table` (
  `mac` varchar(32) NOT NULL,
  `switch` int(16) DEFAULT NULL,
  `port` int(32) DEFAULT NULL,
  `ip` varchar(32) DEFAULT NULL,
  `updated` int(32) NOT NULL,
  PRIMARY KEY (`mac`),
  UNIQUE KEY `mac_2` (`mac`),
  KEY `mac` (`mac`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `netlist`
--

CREATE TABLE IF NOT EXISTS `netlist` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `network` varchar(16) NOT NULL,
  `subnet` varchar(16) NOT NULL,
  `vlan` int(12) DEFAULT NULL,
  `coreswitch` int(12) DEFAULT NULL,
  `dhcp` int(1) DEFAULT '0',
  `dhcp_reserved` varchar(12) DEFAULT '0',
  `last_dhcp_request` varchar(32) DEFAULT '0',
  `desc` varchar(64) DEFAULT NULL,
  `in_use` int(1) DEFAULT '1',
  `master` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `placements`
--

CREATE TABLE IF NOT EXISTS `placements` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `switch` int(12) NOT NULL,
  `x1` int(32) NOT NULL,
  `y1` int(32) NOT NULL,
  `x2` int(32) NOT NULL,
  `y2` int(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `ports`
--

CREATE TABLE IF NOT EXISTS `ports` (
  `id` int(32) NOT NULL AUTO_INCREMENT,
  `switch_id` int(12) NOT NULL,
  `ifIndex` int(6) NOT NULL,
  `ifHighSpeed` int(8) NOT NULL,
  `ifName` varchar(128) DEFAULT NULL,
  `ifPhysAddress` varchar(64) DEFAULT NULL,
  `current_in` bigint(128) DEFAULT NULL,
  `current_out` bigint(128) DEFAULT NULL,
  `updated` int(32) DEFAULT NULL,
  `status` int(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `ports_poll`
--

CREATE TABLE IF NOT EXISTS `ports_poll` (
  `time` int(32) NOT NULL,
  `switch` int(11) NOT NULL,
  `port` int(11) NOT NULL,
  `bytes_in` bigint(20) NOT NULL,
  `bytes_out` bigint(20) NOT NULL,
  PRIMARY KEY (`time`,`switch`,`port`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `switches`
--

CREATE TABLE IF NOT EXISTS `switches` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `model` varchar(45) DEFAULT NULL,
  `desc` text,
  `ip` varchar(45) DEFAULT NULL,
  `snmp_version` int(1) DEFAULT NULL,
  `net_id` int(12) DEFAULT NULL,
  `configured` int(1) DEFAULT '0',
  `type` int(2) DEFAULT '1',
  `connected_to` int(12) DEFAULT NULL,
  `connected_port` varchar(12) DEFAULT NULL,
  `updated` varchar(32) DEFAULT NULL,
  `latency_ms` double DEFAULT NULL,
  `cpu_use` int(3) DEFAULT NULL,
  `uptime` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `switches_ping`
--

CREATE TABLE IF NOT EXISTS `switches_ping` (
  `switch` int(11) NOT NULL,
  `updated` int(33) NOT NULL,
  `latency_ms` double DEFAULT NULL,
  PRIMARY KEY (`updated`,`switch`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `syslog`
--

CREATE TABLE IF NOT EXISTS `syslog` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `time` int(32) NOT NULL,
  `from` varchar(32) NOT NULL,
  `priority` int(32) NOT NULL,
  `message` varchar(128) NOT NULL,
  `type` int(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;
