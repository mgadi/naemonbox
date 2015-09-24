-- phpMyAdmin SQL Dump
-- version 3.3.7deb7
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Sam 11 Mai 2013 à 10:03
-- Version du serveur: 5.1.66
-- Version de PHP: 5.3.3-7+squeeze15

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de données: `syslog`
--

-- --------------------------------------------------------

--
-- Structure de la table `syslog`
--

DROP TABLE IF EXISTS `syslog`;
CREATE TABLE IF NOT EXISTS `syslog` (
  `facility_id` int(10) unsigned DEFAULT NULL,
  `priority_id` int(10) unsigned DEFAULT NULL,
  `host_id` int(10) unsigned DEFAULT NULL,
  `logtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `message` varchar(1024) DEFAULT NULL,
  `seq` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`seq`),
  KEY `facility_id` (`facility_id`),
  KEY `priority_id` (`priority_id`),
  KEY `host_id` (`host_id`),
  KEY `logtime` (`logtime`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=67625 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_alert`
--

DROP TABLE IF EXISTS `syslog_alert`;
CREATE TABLE IF NOT EXISTS `syslog_alert` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `severity` int(10) unsigned NOT NULL DEFAULT '0',
  `method` int(10) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '1',
  `type` varchar(16) NOT NULL DEFAULT '',
  `enabled` char(2) DEFAULT 'on',
  `message` varchar(128) DEFAULT NULL,
  `user` varchar(32) NOT NULL DEFAULT '',
  `date` int(16) NOT NULL DEFAULT '0',
  `email` text NOT NULL,
  `command` varchar(255) DEFAULT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_facilities`
--

DROP TABLE IF EXISTS `syslog_facilities`;
CREATE TABLE IF NOT EXISTS `syslog_facilities` (
  `facility_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `facility` varchar(10) NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`facility`),
  KEY `facility_id` (`facility_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=18 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_hosts`
--

DROP TABLE IF EXISTS `syslog_hosts`;
CREATE TABLE IF NOT EXISTS `syslog_hosts` (
  `host_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `host` varchar(128) NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`host`),
  KEY `host_id` (`host_id`),
  KEY `last_updated` (`last_updated`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='Contains all hosts currently in the syslog table' AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_host_facilities`
--

DROP TABLE IF EXISTS `syslog_host_facilities`;
CREATE TABLE IF NOT EXISTS `syslog_host_facilities` (
  `host_id` int(10) unsigned NOT NULL,
  `facility_id` int(10) unsigned NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`host_id`,`facility_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_incoming`
--

DROP TABLE IF EXISTS `syslog_incoming`;
CREATE TABLE IF NOT EXISTS `syslog_incoming` (
  `facility` varchar(10) DEFAULT NULL,
  `priority` varchar(10) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `host` varchar(128) DEFAULT NULL,
  `message` text,
  `seq` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`seq`),
  KEY `status` (`status`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=67734 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_logs`
--

DROP TABLE IF EXISTS `syslog_logs`;
CREATE TABLE IF NOT EXISTS `syslog_logs` (
  `alert_id` int(10) unsigned NOT NULL DEFAULT '0',
  `logseq` bigint(20) unsigned NOT NULL,
  `logtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `logmsg` varchar(1024) DEFAULT NULL,
  `host` varchar(32) DEFAULT NULL,
  `facility` varchar(10) DEFAULT NULL,
  `priority` varchar(10) DEFAULT NULL,
  `count` int(10) unsigned NOT NULL DEFAULT '0',
  `html` blob,
  `seq` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`seq`),
  KEY `logseq` (`logseq`),
  KEY `alert_id` (`alert_id`),
  KEY `host` (`host`),
  KEY `seq` (`seq`),
  KEY `logtime` (`logtime`),
  KEY `priority` (`priority`),
  KEY `facility` (`facility`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_priorities`
--

DROP TABLE IF EXISTS `syslog_priorities`;
CREATE TABLE IF NOT EXISTS `syslog_priorities` (
  `priority_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `priority` varchar(10) NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`priority`),
  KEY `priority_id` (`priority_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_remove`
--

DROP TABLE IF EXISTS `syslog_remove`;
CREATE TABLE IF NOT EXISTS `syslog_remove` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(16) NOT NULL DEFAULT '',
  `enabled` char(2) DEFAULT 'on',
  `method` char(5) DEFAULT 'del',
  `message` varchar(128) DEFAULT NULL,
  `user` varchar(32) NOT NULL DEFAULT '',
  `date` int(16) NOT NULL DEFAULT '0',
  `notes` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_removed`
--

DROP TABLE IF EXISTS `syslog_removed`;
CREATE TABLE IF NOT EXISTS `syslog_removed` (
  `facility_id` int(10) unsigned DEFAULT NULL,
  `priority_id` int(10) unsigned DEFAULT NULL,
  `host_id` int(10) unsigned DEFAULT NULL,
  `logtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `message` varchar(1024) DEFAULT NULL,
  `seq` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`seq`),
  KEY `facility_id` (`facility_id`),
  KEY `priority_id` (`priority_id`),
  KEY `host_id` (`host_id`),
  KEY `logtime` (`logtime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_reports`
--

DROP TABLE IF EXISTS `syslog_reports`;
CREATE TABLE IF NOT EXISTS `syslog_reports` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(16) NOT NULL DEFAULT '',
  `enabled` char(2) DEFAULT 'on',
  `timespan` int(16) NOT NULL DEFAULT '0',
  `timepart` char(5) NOT NULL DEFAULT '00:00',
  `lastsent` int(16) NOT NULL DEFAULT '0',
  `body` varchar(1024) DEFAULT NULL,
  `message` varchar(128) DEFAULT NULL,
  `user` varchar(32) NOT NULL DEFAULT '',
  `date` int(16) NOT NULL DEFAULT '0',
  `email` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `syslog_statistics`
--

DROP TABLE IF EXISTS `syslog_statistics`;
CREATE TABLE IF NOT EXISTS `syslog_statistics` (
  `host_id` int(10) unsigned NOT NULL,
  `facility_id` int(10) unsigned NOT NULL,
  `priority_id` int(10) unsigned NOT NULL,
  `insert_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `records` int(10) unsigned NOT NULL,
  PRIMARY KEY (`host_id`,`facility_id`,`priority_id`,`insert_time`),
  KEY `host_id` (`host_id`),
  KEY `facility_id` (`facility_id`),
  KEY `priority_id` (`priority_id`),
  KEY `insert_time` (`insert_time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Maintains High Level Statistics';

