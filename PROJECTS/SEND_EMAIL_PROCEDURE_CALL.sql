create or replace PROCEDURE                                      send_email_alerts
  IS
    CURSOR email_q
    IS
      SELECT * FROM ds3_userdata.email_alerts WHERE sent IS NULL FOR UPDATE;
    l_from    VARCHAR2 (3000); 
    l_to      VARCHAR2 (3000);
    l_cc      VARCHAR2 (3000);
    l_subject VARCHAR2 (120);
    l_message CLOB;
    l_note       VARCHAR2 (32000);
    e_msg_header VARCHAR2 (1000) := '<html><body>';
    e_msg_footer VARCHAR2 (20)   := '</body></html>';
  BEGIN
    FOR rec IN email_q
    LOOP
      l_to            := rec.addrto;
      l_cc            := rec.addrcc;
      l_subject       := rec.alert || ': ' || rec.subject;
      IF rec.addrfrom IS NULL THEN
        l_from        := 'kinnate@gmail.com';
      else   
        l_from        := rec.addrfrom;
      END IF;



      ds3_userdata.SEND_MAIL2(P_FROM => l_from, p_TO => l_to, p_CC => l_cc, p_SUB => l_subject, p_body => rec.alert_text, p_ishtml=>1);


      UPDATE ds3_userdata.email_alerts SET sent = 1 WHERE CURRENT OF email_q;
    END LOOP;
    COMMIT;
  END;
