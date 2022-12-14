create or replace procedure send_mail2 (p_from varchar2, p_to varchar2,p_cc varchar2,p_sub varchar2,p_body varchar2, p_ishtml number DEFAULT 0)
as 

  k_host            CONSTANT VARCHAR2(100) := 'smtp.office365.com';
  k_port            CONSTANT INTEGER       := 587;
  k_wallet_path     CONSTANT VARCHAR2(100) := 'file:/opt/oracle/admin/ora_dm/wallets/officeWal';
  k_wallet_password CONSTANT VARCHAR2(100) := 'Letmein1!';
  k_domain          CONSTANT VARCHAR2(100) := 'office365.com'; 
  k_username        CONSTANT VARCHAR2(100) := 'apps@kinnate.com';
  k_password        CONSTANT VARCHAR2(100) := 'P@ssword12&1';
  k_sender          CONSTANT VARCHAR2(100) := 'apps@kinnate.com';
  k_recipient       CONSTANT VARCHAR2(100) := 'jgolubev@gmail.com';
  k_subject         CONSTANT VARCHAR2(100) := 'Test TLS mail';
  k_body            CONSTANT VARCHAR2(100) := 'Message body';
  l_conn    utl_smtp.connection;
  l_reply   utl_smtp.reply;
  l_replies utl_smtp.replies;
  k_tolist          VARCHAR2(4000):='';

  BEGIN
    dbms_output.put_line('utl_smtp.open_connection');

    l_reply := utl_smtp.open_connection
               ( host                          => k_host
               , port                          => k_port
               , c                             => l_conn
               , wallet_path                   => k_wallet_path
               , wallet_password               => k_wallet_password
               , secure_connection_before_smtp => FALSE
               );

    IF l_reply.code != 220
    THEN
      raise_application_error(-20000, 'utl_smtp.open_connection: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.ehlo');

    l_replies := utl_smtp.ehlo(l_conn, k_domain);

    FOR ri IN 1..l_replies.COUNT
    LOOP
      dbms_output.put_line(l_replies(ri).code||' - '||l_replies(ri).text);
    END LOOP;

    dbms_output.put_line('utl_smtp.starttls');

    l_reply := utl_smtp.starttls(l_conn);

    IF l_reply.code != 220
    THEN
      raise_application_error(-20000, 'utl_smtp.starttls: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.ehlo');

    l_replies := utl_smtp.ehlo(l_conn, k_domain);

    FOR ri IN 1..l_replies.COUNT
    LOOP
      dbms_output.put_line(l_replies(ri).code||' - '||l_replies(ri).text);
    END LOOP;

    dbms_output.put_line('utl_smtp.auth');

    l_reply := utl_smtp.auth(l_conn, k_username, k_password, 'LOGIN');

    IF l_reply.code != 235
    THEN
      raise_application_error(-20000, 'utl_smtp.auth: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.mail');

    l_reply := utl_smtp.mail(l_conn, p_from);

    IF l_reply.code != 250
    THEN
      raise_application_error(-20000, 'utl_smtp.mail: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.rcpt');

    FOR i IN
    (
      SELECT column_value AS recipient FROM TABLE(ds3_userdata.split(p_to))
    )
    LOOP      
       l_reply := utl_smtp.rcpt(l_conn, i.recipient);

        IF l_reply.code NOT IN (250, 251)
        THEN
          raise_application_error(-20000, 'utl_smtp.rcpt: '||l_reply.code||' - '||l_reply.text);
        END IF;
    END LOOP;



    dbms_output.put_line('utl_smtp.open_data');

    l_reply := utl_smtp.open_data(l_conn);

    IF l_reply.code != 354
    THEN
      raise_application_error(-20000, 'utl_smtp.open_data: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.write_data');

    utl_smtp.write_data(l_conn, 'From: '||p_from||utl_tcp.crlf);


    FOR i IN
    (
      SELECT column_value AS recipient FROM TABLE(ds3_userdata.split(p_to))
    )
    LOOP  
        if k_tolist is null then
            k_tolist:= k_tolist || i.recipient;
        else
            k_tolist:= k_tolist ||','||i.recipient;
        end if;
       --utl_smtp.write_data(l_conn, 'To: '||i.recipient||utl_tcp.crlf);
    END LOOP;

    utl_smtp.write_data(l_conn, 'To: '||k_tolist||utl_tcp.crlf);

    FOR i IN
    (
      SELECT column_value AS recipient FROM TABLE(ds3_userdata.split(p_cc))
    )
    LOOP
      utl_smtp.write_data(l_conn, 'Cc: '||i.recipient||utl_tcp.crlf);
    END LOOP;


    utl_smtp.write_data(l_conn, 'Subject: '||p_sub||utl_tcp.crlf);

    UTL_SMTP.write_data(l_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf);

    if p_ishtml = 1
    then
       UTL_SMTP.write_data(l_conn, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
    end if;
    utl_smtp.write_data(l_conn, utl_tcp.crlf||p_body);

    dbms_output.put_line('utl_smtp.close_data');

    l_reply := utl_smtp.close_data(l_conn);

    IF l_reply.code != 250
    THEN
      raise_application_error(-20000, 'utl_smtp.close_data: '||l_reply.code||' - '||l_reply.text);
    END IF;

    dbms_output.put_line('utl_smtp.quit');

    l_reply := utl_smtp.quit(l_conn);

    IF l_reply.code != 221
    THEN
      raise_application_error(-20000, 'utl_smtp.quit: '||l_reply.code||' - '||l_reply.text);
    END IF;

  EXCEPTION
    WHEN    utl_smtp.transient_error
         OR utl_smtp.permanent_error
    THEN
      BEGIN
        utl_smtp.quit(l_conn);
      EXCEPTION
        WHEN    utl_smtp.transient_error
             OR utl_smtp.permanent_error
        THEN
          NULL;
      END;

      raise_application_error(-20000, 'Failed to send mail due to the following error: '||SQLERRM);

  END;
