--------------------------------------------------------
--  DDL for Table TFA_CONFIGS
--------------------------------------------------------

  CREATE TABLE "TFA_CONFIGS" 
   (	"USERNAME" VARCHAR2(256 BYTE), 
	"SHARED_SECRET" VARCHAR2(100 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table TFA_CODES
--------------------------------------------------------

  CREATE TABLE "TFA_CODES" 
   (	"USERNAME" VARCHAR2(256 BYTE), 
	"OTP_CODE" VARCHAR2(50 BYTE), 
	"TYPE" VARCHAR2(20 BYTE), 
	"USED" VARCHAR2(1 BYTE), 
	"USED_DATE" DATE
   ) ;
--------------------------------------------------------
--  DDL for Index TFA_CONFIGS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "TFA_CONFIGS_PK" ON "TFA_CONFIGS" ("USERNAME") 
  ;
--------------------------------------------------------
--  DDL for Index TFA_CODES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "TFA_CODES_PK" ON "TFA_CODES" ("USERNAME", "OTP_CODE") 
  ;
--------------------------------------------------------
--  Constraints for Table TFA_CONFIGS
--------------------------------------------------------

  ALTER TABLE "TFA_CONFIGS" ADD CONSTRAINT "TFA_CONFIGS_PK" PRIMARY KEY ("USERNAME")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table TFA_CODES
--------------------------------------------------------

  ALTER TABLE "TFA_CODES" ADD CONSTRAINT "TFA_CODES_PK" PRIMARY KEY ("USERNAME", "OTP_CODE")
  USING INDEX  ENABLE;
  ALTER TABLE "TFA_CODES" MODIFY ("TYPE" NOT NULL ENABLE);
  ALTER TABLE "TFA_CODES" MODIFY ("USED" NOT NULL ENABLE);
--------------------------------------------------------
--  Ref Constraints for Table TFA_CODES
--------------------------------------------------------

  ALTER TABLE "TFA_CODES" ADD CONSTRAINT "TFA_CODES_FK_1" FOREIGN KEY ("USERNAME")
	  REFERENCES "TFA_CONFIGS" ("USERNAME") ON DELETE CASCADE ENABLE NOVALIDATE;
