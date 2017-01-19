--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

SET AUTOCOMMIT FALSE;

START TRANSACTION;

--
-- Insert user information into the temporary tables. To add users to the HSQL database, edit things here.
-- 

INSERT INTO users_TEMP (username, password, enabled) VALUES
  ('admin','password',true),
  ('user','password',true),
  ('user2','password', true);


INSERT INTO authorities_TEMP (username, authority) VALUES
  ('admin','ROLE_ADMIN'),
  ('admin','ROLE_USER'),
  ('user','ROLE_USER'),
  ('user2', 'ROLE_USER');
    
-- By default, the username column here has to match the username column in the users table, above
INSERT INTO user_info_TEMP (sub, preferred_username, name, email, email_verified, website) VALUES
  ('90342.ASDFJWFA','admin','Demo Admin','admin@example.com', true, 'ROLE_ADMIN'),
  ('01921.FLANRJQW','user','Enterprise 1','user@enterprise1.com', true, 'ROLE_APPLICATION_B, ROLE_APPLICATION_C'),
  ('01922.FLANTEST','user2','Enterprise 2','user@enterprise2.com', true, '');

 
--
-- Merge the temporary users safely into the database. This is a two-step process to keep users from being created on every startup with a persistent store.
--

MERGE INTO users 
  USING (SELECT username, password, enabled FROM users_TEMP) AS vals(username, password, enabled)
  ON vals.username = users.username
  WHEN NOT MATCHED THEN 
    INSERT (username, password, enabled) VALUES(vals.username, vals.password, vals.enabled);

MERGE INTO authorities 
  USING (SELECT username, authority FROM authorities_TEMP) AS vals(username, authority)
  ON vals.username = authorities.username AND vals.authority = authorities.authority
  WHEN NOT MATCHED THEN 
    INSERT (username,authority) values (vals.username, vals.authority);

MERGE INTO user_info 
  USING (SELECT sub, preferred_username, name, email, email_verified FROM user_info_TEMP) AS vals(sub, preferred_username, name, email, email_verified)
  ON vals.preferred_username = user_info.preferred_username
  WHEN NOT MATCHED THEN 
    INSERT (sub, preferred_username, name, email, email_verified) VALUES (vals.sub, vals.preferred_username, vals.name, vals.email, vals.email_verified);

    
-- 
-- Close the transaction and turn autocommit back on
-- 
    
COMMIT;

SET AUTOCOMMIT TRUE;

