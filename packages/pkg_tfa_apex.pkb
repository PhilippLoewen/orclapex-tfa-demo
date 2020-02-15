CREATE OR REPLACE PACKAGE BODY pkg_tfa_apex AS
  /**
   * TODO_Comments
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  -
   *
   * @author TODO
   * @created TODO
   * @param TODO
   * @return TODO
   */
  --

  /**
   * TODO_Comments
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  -
   *
   * @author TODO
   * @created TODO
   * @param TODO
   * @return TODO
   */
  --

    PROCEDURE p_register_user (
        p_username           IN                   VARCHAR2,
        p_password           IN                   VARCHAR2,
        p_confirm_password   IN                   VARCHAR2
    ) AS
        illegal_arguments_error EXCEPTION;
        login_failed EXCEPTION;
    BEGIN
        IF p_username IS NULL OR p_password IS NULL OR p_password != p_confirm_password THEN
            RAISE illegal_arguments_error;
        END IF;

        apex_util.create_user(p_user_name => p_username, p_web_password => p_password, p_change_password_on_first_use => 'N');

    EXCEPTION
        WHEN OTHERS THEN
      -- error handling
            RAISE;
    END p_register_user;

  /**
   * TODO_Comments
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  -
   *
   * @author TODO
   * @created TODO
   * @param TODO
   * @return TODO
   */
  --


    FUNCTION f_enable_otp (
        p_username IN VARCHAR2
    ) RETURN VARCHAR2 IS
        l_num_results     PLS_INTEGER := -1;
        l_shared_secret   tfa_configs.shared_secret%TYPE;
    BEGIN
        WHILE l_num_results != 0 LOOP
            l_shared_secret := oos_util_totp.generate_secret;
            SELECT
                COUNT(1)
            INTO l_num_results
            FROM
                tfa_configs
            WHERE
                shared_secret = l_shared_secret;

        END LOOP;

        INSERT INTO tfa_configs (
            username,
            shared_secret
        ) VALUES (
            p_username,
            l_shared_secret
        );

        RETURN l_shared_secret;
    END f_enable_otp;

    PROCEDURE p_authenticate_user (
        p_username   IN           VARCHAR2,
        p_password   IN           VARCHAR2
    ) AS
        l_tfa_enabled   NUMBER;
        login_failed EXCEPTION;
        l_username      tfa_configs.username%TYPE := upper(p_username);
    BEGIN
        BEGIN
            SELECT
                COUNT(*)
            INTO l_tfa_enabled
            FROM
                tfa_configs tc
            WHERE
                tc.username = l_username;

        EXCEPTION
            WHEN no_data_found THEN
                RAISE login_failed;
        END;

        IF apex_util.is_login_password_valid(p_username => l_username, p_password => p_password) THEN
            IF l_tfa_enabled = 0 THEN
                apex_authentication.post_login(p_username => l_username, p_password => p_password);
                apex_util.clear_page_cache();
            END IF;

        ELSE
            RAISE login_failed;
        END IF;

    EXCEPTION
        WHEN login_failed THEN
            apex_authentication.login(p_username => l_username, p_password => NULL);
    END p_authenticate_user;



  /**
   * TODO_Comments
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  -
   *
   * @author TODO
   * @created TODO
   * @param TODO
   * @return TODO
   */
  --

    FUNCTION f_validate_otp (
        p_username   IN           tfa_configs.username%TYPE,
        p_otp        IN           NUMBER
    ) RETURN BOOLEAN AS

        l_shared_secret   tfa_configs.shared_secret%TYPE;
        l_username        tfa_configs.username%TYPE := upper(p_username);
        l_is_valid        BOOLEAN := false;
        l_count           NUMBER;
        l_tfa_code_row    tfa_codes%rowtype;
    BEGIN
        SELECT
            shared_secret
        INTO l_shared_secret
        FROM
            tfa_configs
        WHERE
            1 = 1
            AND username = l_username;

        l_is_valid := oos_util_totp.validate_otp(p_secret => l_shared_secret, p_otp => p_otp) = 1;

        BEGIN
            SELECT
                *
            INTO l_tfa_code_row
            FROM
                tfa_codes tc
            WHERE
                tc.username = l_username
                AND tc.otp_code = p_otp;

        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        IF l_tfa_code_row.username IS NOT NULL THEN
            IF l_tfa_code_row.used = 'N' THEN
                UPDATE tfa_codes tc
                SET
                    tc.used = 'Y',
                    tc.used_date = SYSDATE
                WHERE
                    tc.username = l_username
                    AND tc.otp_code = p_otp;

                l_is_valid := true;
            ELSE
                l_is_valid := false;
            END IF;
        ELSE
            INSERT INTO tfa_codes tc (
                username,
                otp_code,
                type,
                used,
                used_date
            ) VALUES (
                l_username,
                p_otp,
                'TOTP',
                'Y',
                SYSDATE
            );

        END IF;

        RETURN l_is_valid;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN false;
    END f_validate_otp;

END pkg_tfa_apex;
/