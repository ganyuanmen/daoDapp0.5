CREATE DATABASE `dao_db` character set utf8mb4;
USE `dao_db`;


CREATE TABLE `t_changelogo` (
  `dao_id` INT NOT NULL COMMENT 'dao id',
  `block_num` BIGINT NOT NULL COMMENT '区块号',
  `dao_time` INT DEFAULT NULL COMMENT '时间戳',
  `dao_logo` TEXT  COMMENT 'svg logo',
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dao_id`),
  UNIQUE KEY `block_num` (`block_num`)
) ;


CREATE TABLE `t_dao` (
  `dao_id` INT NOT NULL COMMENT 'dao ID',
  `block_num` BIGINT DEFAULT NULL COMMENT '区块号',
  `dao_name` VARCHAR(2000) DEFAULT NULL COMMENT '名称',
  `dao_symbol` VARCHAR(2000) DEFAULT NULL COMMENT 'DAO 符号',
  `dao_dsc` VARCHAR(4000) DEFAULT NULL COMMENT '描述',
  `dao_time` INT DEFAULT NULL COMMENT '时间戳',
  `dao_manager` VARCHAR(128)  DEFAULT NULL COMMENT '管理员地址',
  `dao_logo` TEXT  COMMENT 'svg logo',
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `utoken_cost` DECIMAL(18,4) DEFAULT NULL COMMENT '币值',
  `dao_index` INT DEFAULT NULL COMMENT '排名',
  PRIMARY KEY (`dao_id`),
  UNIQUE KEY `block_num` (`block_num`)
) ;


CREATE TABLE `t_os` (
  `dao_id` INT NOT NULL COMMENT 'dao id',
  `block_num` BIGINT NOT NULL COMMENT '区块号',
  `os_address` VARCHAR(128)  DEFAULT NULL COMMENT 'os 地址',
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dao_id`),
  UNIQUE KEY `block_num` (`block_num`)
) ;


CREATE TABLE `t_setlogo` (
  `dao_id` INT NOT NULL COMMENT 'dao id',
  `block_num` BIGINT NOT NULL COMMENT '区块号',
  `dao_time` INT DEFAULT NULL COMMENT '时间戳',
  `dao_logo` TEXT  COMMENT 'svg图片',
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dao_id`),
  UNIQUE KEY `block_num` (`block_num`)
) ;


CREATE TABLE `t_t2t` (
  `block_num` BIGINT NOT NULL,
  `from_token_id` INT DEFAULT NULL,
  `to_token_id` INT DEFAULT NULL,
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `from_utoken_cost` DECIMAL(18,4) DEFAULT NULL,
  `to_utoken_cost` DECIMAL(18,4) DEFAULT NULL,
  PRIMARY KEY (`block_num`)
) ;


CREATE TABLE `t_t2u` (
  `block_num` BIGINT NOT NULL,
  `from_token_id` INT DEFAULT NULL,
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `utoken_cost` DECIMAL(18,4) DEFAULT NULL,
  PRIMARY KEY (`block_num`)
) ;


CREATE TABLE `t_token` (
  `dao_id` INT NOT NULL COMMENT 'dao Id',
  `block_num` BIGINT NOT NULL COMMENT '区块号',
  `dao_time` INT DEFAULT NULL COMMENT '时间戳',
  `token_id` INT DEFAULT NULL COMMENT 'token ID',
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dao_id`),
  UNIQUE KEY `block_num` (`block_num`)
) ;


CREATE TABLE `t_u2t` (
  `block_num` BIGINT NOT NULL,
  `to_token_id` INT DEFAULT NULL,
  `_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `utoken_cost` DECIMAL(18,4) DEFAULT NULL,
  PRIMARY KEY (`block_num`)
) ;


DELIMITER $$



 CREATE TRIGGER `changeLogotrigger` AFTER INSERT ON `t_changelogo` FOR EACH ROW BEGIN
	UPDATE t_dao SET dao_logo=new.dao_logo WHERE dao_id=new.dao_id;
    END 
    
    $$


DELIMITER ;



DELIMITER $$


 CREATE TRIGGER `setLogotrigger` AFTER INSERT ON `t_setlogo` FOR EACH ROW BEGIN
	UPDATE t_dao SET dao_logo=new.dao_logo WHERE dao_id=new.dao_id;
    END $$


DELIMITER ;



DELIMITER $$



CREATE TRIGGER `t2t_regisster` AFTER INSERT ON `t_t2t` FOR EACH ROW BEGIN
	UPDATE t_dao SET utoken_cost=new.from_utoken_cost WHERE dao_id IN(SELECT dao_id FROM t_token WHERE token_id=new.from_token_id);
	UPDATE t_dao SET utoken_cost=new.to_utoken_cost WHERE dao_id IN(SELECT dao_id FROM t_token WHERE token_id=new.to_token_id);
    END $$


DELIMITER ;


DELIMITER $$



 CREATE TRIGGER `t2u_regisster` AFTER INSERT ON `t_t2u` FOR EACH ROW BEGIN
	UPDATE t_dao SET utoken_cost=new.utoken_cost WHERE dao_id IN(SELECT dao_id FROM t_token WHERE token_id=new.from_token_id);
    END $$


DELIMITER ;



DELIMITER $$
CREATE TRIGGER `u2t_regisster` AFTER INSERT ON `t_u2t` FOR EACH ROW BEGIN
	UPDATE t_dao SET utoken_cost=new.utoken_cost WHERE dao_id IN(SELECT dao_id FROM t_token WHERE token_id=new.to_token_id);
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `excuteOs`($blockNum BIGINT, $daoId INT,$osAddress VARCHAR(50))
BEGIN
	IF EXISTS(SELECT * FROM t_os WHERE dao_id=$daoId) THEN 
		UPDATE t_os SET block_num=$blockNum,os_address=$osAddress WHERE dao_id=$daoId;
	ELSE
		INSERT INTO t_os(dao_id,os_address,block_num) VALUES($daoId,$osAddress,$blockNum) ;
	END IF;
	
    END $$
DELIMITER ;


CREATE VIEW `v_dao` AS SELECT `a`.`dao_id` AS `dao_id`,`a`.`block_num` AS `block_num`,`a`.`dao_name` AS `dao_name`,`a`.`dao_symbol` AS `dao_symbol`,`a`.`dao_dsc` AS `dao_dsc`,DATE_FORMAT(FROM_UNIXTIME(`a`.`dao_time`),'%Y-%m-%d') AS `dao_time`,`a`.`dao_manager` AS `dao_manager`,`a`.`dao_logo` AS `dao_logo`,`a`.`_time` AS `_time`,`a`.`utoken_cost` AS `utoken_cost`,`a`.`dao_index` AS `dao_index`,`d`.`dao_id` AS `logodao_id`,`b`.`os_address` AS `os_address`,`c`.`token_id` AS `token_id` FROM (((`t_dao` `a` LEFT JOIN `t_os` `b` ON((`a`.`dao_id` = `b`.`dao_id`))) LEFT JOIN `t_token` `c` ON((`a`.`dao_id` = `c`.`dao_id`))) LEFT JOIN `t_setlogo` `d` ON((`a`.`dao_id` = `d`.`dao_id`))) ;



