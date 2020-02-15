CREATE OR REPLACE PACKAGE pkg_tfa_apex AS
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
    );

    FUNCTION f_enable_otp (
        p_username IN VARCHAR2
    ) RETURN VARCHAR2;

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

    PROCEDURE p_authenticate_user (
        p_username   IN           VARCHAR2,
        p_password   IN           VARCHAR2
    );

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
    ) RETURN BOOLEAN;

END pkg_tfa_apex;
/