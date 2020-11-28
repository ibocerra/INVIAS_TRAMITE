-- Generado por Oracle SQL Developer Data Modeler 20.2.0.167.1538
--   en:        2020-11-28 00:19:04 COT
--   sitio:      Oracle Database 10g
--   tipo:      Oracle Database 10g



CREATE TABLESPACE tramitedat 
--  WARNING: Tablespace has no data files defined 
 LOGGING ONLINE EXTENT MANAGEMENT LOCAL AUTOALLOCATE FLASHBACK ON;

CREATE TABLESPACE tramiteind 
--  WARNING: Tablespace has no data files defined 
 LOGGING ONLINE EXTENT MANAGEMENT LOCAL AUTOALLOCATE FLASHBACK ON;

CREATE ROLE interventor NOT IDENTIFIED;

CREATE ROLE tramite_consulta NOT IDENTIFIED;

CREATE user tramite identified by account unlock 
;

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE OR REPLACE PACKAGE           TRAMITE.GLOBALPKG 
 AUTHID
    CURRENT_USER AS
  identity  INTEGER;
  trancount INTEGER;
  TYPE RCT18 IS REF CURSOR;
 END globalPkg;
/

CREATE OR REPLACE FUNCTION tramite.remolque_soli (
    soli IN VARCHAR2
) RETURN VARCHAR2 IS

    ret     VARCHAR2(4000);
    TYPE cur_typ IS REF CURSOR;
    rec     cur_typ;
    field   VARCHAR2(200);
    sqlstr  VARCHAR2(6000);
BEGIN
    sqlstr := 'select RM.REMO_PLACA from solicitudcargaremolque sr
        join remolque rm on RM.REMO_ID = SR.REMO_ID
        where soli_id = ' ||
    soli;
    OPEN rec FOR sqlstr;
    /*select remo_placa into rec from remolque where soli_id = soli;*/ 
         LOOP
        FETCH rec INTO field;
        EXIT WHEN rec%notfound;
        ret := ret
               || field
               || ', ';
    END LOOP;

    IF length(ret) = 0 THEN
        RETURN '';
    ELSE
        RETURN substr(ret, 1, length(ret) - 2);
    END IF;

END;
/

CREATE OR REPLACE FUNCTION tramite.split (
    p_in_string  VARCHAR2,
    p_delim      VARCHAR2
) RETURN t_array IS
 /*create type t_array as table of varchar2(100)*/
       i        NUMBER := 0;
    pos      NUMBER := 0;
    lv_str   VARCHAR2(50) := ltrim(p_in_string, p_delim);
    strings  t_array := t_array();
BEGIN
   -- determine first chuck of string
       pos := instr(lv_str, p_delim, 1, 1);
   -- while there are chunks left, loop
       WHILE ( pos != 0 ) LOOP
     -- increment counter
             i := i + 1;
     -- create array element for chuck of string
             strings.extend;
        strings(i) := substr(lv_str, 1, pos - 1);
     -- remove chunk from string
             lv_str := substr(lv_str, pos + 1, length(lv_str));
     -- determine next chunk
             pos := instr(lv_str,
        p_delim, 1, 1);
     -- no last chunk, add to array
             IF pos = 0 THEN
            strings.extend;
            strings(i + 1) := lv_str;
        END IF;

    END LOOP;
   -- return array
       RETURN strings;
END split;
/

CREATE TABLE tramite.solicitud (
    soli_id                NUMBER(30) NOT NULL,
    tram_id                NUMBER(30) NOT NULL,
    soli_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    soli_fechacambio       DATE NOT NULL,
    soli_activarimpresion  VARCHAR2(1 BYTE) NOT NULL,
    soli_activo            VARCHAR2(1 BYTE) NOT NULL,
    soli_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    soli_fecha             DATE NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    esso_id                NUMBER(30) NOT NULL,
    soli_radicado          VARCHAR2(30 BYTE),
    soli_desccambio        VARCHAR2(300 BYTE),
    asignado               NUMBER(*, 0),
    soli_asignado          VARCHAR2(10 BYTE),
    soli_nomcambio         VARCHAR2(50 BYTE),
    control_sat            NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT ck_soli_activarimpresion CHECK ( soli_activarimpresion IN ( 'A', 'I' ) );

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT ck_soli_activo CHECK ( soli_activo IN ( 'N', 'S' ) );

COMMENT ON TABLE tramite.solicitud IS
    'Almacena las solicitudes de tramites';

COMMENT ON COLUMN tramite.solicitud.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitud.tram_id IS
    'ALMACENA EL IDENTIFICADOR DEL TRAMITE';

COMMENT ON COLUMN tramite.solicitud.soli_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitud.soli_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitud.soli_activarimpresion IS
    'ALMACENA CUANDO SE ACTIVA LA IMPRESION DE LA SOLICITUD';

COMMENT ON COLUMN tramite.solicitud.soli_activo IS
    'ALMACENA SI LA SOLICITUD ESTA ACTIVA O NO, S=SI Y N=NO';

COMMENT ON COLUMN tramite.solicitud.soli_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitud.soli_fecha IS
    'ALMACENA LA FECHA DE LA SOLICITUD';

COMMENT ON COLUMN tramite.solicitud.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA PERSONA';

CREATE UNIQUE INDEX tramite.ck_soli_radicado ON
    tramite.solicitud (
        soli_radicado
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_soli ON
    tramite.solicitud (
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.solicitud TO tramite_consulta;

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT pk_soli PRIMARY KEY ( soli_id )
        USING INDEX tramite.pk_soli;

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT ck_soli_radicado UNIQUE ( soli_radicado )
        USING INDEX tramite.ck_soli_radicado;

CREATE TABLE tramite.solicitudestacion (
    soli_id                       NUMBER(30) NOT NULL,
    soes_codigovia                VARCHAR2(102 BYTE),
    soes_inicio_pr                VARCHAR2(20 BYTE),
    soes_fin_pr                   VARCHAR2(20 BYTE),
    soes_descripcion              VARCHAR2(200 BYTE),
    soes_costado                  VARCHAR2(15 BYTE),
    soes_espropietario            NUMBER(*, 0),
    depa_id                       NUMBER(5),
    muni_id                       NUMBER(8),
    soes_tipopredio               VARCHAR2(15 BYTE),
    soes_proyecto                 VARCHAR2(2600 BYTE),
    soes_propietarionombre        VARCHAR2(500 BYTE),
    soes_propietariocedula        VARCHAR2(100 BYTE),
    soes_propietariotelefono      VARCHAR2(100 BYTE),
    soes_propietariocelular       VARCHAR2(100 BYTE),
    soes_propietariodireccion     VARCHAR2(500 BYTE),
    soes_propietariocorreo        VARCHAR2(500 BYTE),
    soes_numeromatricula          VARCHAR2(100 BYTE),
    soes_cedulacatastral          VARCHAR2(100 BYTE),
    soes_circulocatastral         VARCHAR2(100 BYTE),
    muni_id_catastral             NUMBER(8),
    depa_id_catastral             NUMBER(8),
    soes_apoderadonombre          VARCHAR2(500 BYTE),
    soes_apoderadocedula          VARCHAR2(100 BYTE),
    soes_apoderadotelefono        VARCHAR2(100 BYTE),
    soes_apoderadocelular         VARCHAR2(100 BYTE),
    soes_apoderadodireccion       VARCHAR2(500 BYTE),
    soes_apoderadocorreo          VARCHAR2(500 BYTE),
    soes_primerafecha             DATE,
    soes_segundafecha             DATE,
    soes_tercerafecha             DATE,
    soes_fechaseleccionada        DATE,
    soes_entidadusosuelo          VARCHAR2(500 BYTE),
    soes_fechausosuelo            DATE,
    soes_tipousosuelo             VARCHAR2(300 BYTE),
    soes_resolucionnumero         VARCHAR2(300 BYTE),
    soes_resolucionfecha          DATE,
    soes_resoluciontiposuelo      VARCHAR2(300 BYTE),
    depa_id_resolucion            NUMBER(8),
    muni_id_resolucion            NUMBER(8),
    soes_planonombre              VARCHAR2(300 BYTE),
    soes_planoprofesion           VARCHAR2(300 BYTE),
    soes_planoprofesional         VARCHAR2(300 BYTE),
    soes_planofecha               DATE,
    soes_primerafranja            VARCHAR2(100 BYTE),
    soes_segundafranja            VARCHAR2(100 BYTE),
    soes_tercerafranja            VARCHAR2(100 BYTE),
    soes_franjaselccionada        VARCHAR2(100 BYTE),
    soes_esfavorable              NUMBER(*, 0),
    soes_obscertificado           VARCHAR2(4000 BYTE),
    soes_obsplano                 VARCHAR2(4000 BYTE),
    soes_obslicencia              VARCHAR2(4000 BYTE),
    soes_cumplecertificadoconcep  VARCHAR2(500 BYTE),
    soes_cumpleplanoconcep        VARCHAR2(500 BYTE),
    soes_cumplelicenciaconcep     VARCHAR2(500 BYTE),
    soes_obscertificadoconcep     VARCHAR2(4000 BYTE),
    soes_obsplanoconcep           VARCHAR2(4000 BYTE),
    soes_obslicenciaconcep        VARCHAR2(4000 BYTE),
    soes_proyecta                 VARCHAR2(3000 BYTE),
    soes_revisa                   VARCHAR2(3000 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudestacion_pk ON
    tramite.solicitudestacion (
        soli_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudestacion
    ADD CONSTRAINT solicitudestaciones_pk PRIMARY KEY ( soli_id )
        USING INDEX tramite.solicitudestacion_pk;

CREATE TABLE tramite.archivo_session (
    arcs_id                NUMBER(30) NOT NULL,
    arcs_extension         VARCHAR2(10 BYTE),
    arcs_nombre            VARCHAR2(100 BYTE) NOT NULL,
    arcs_archivo           BLOB,
    arcs_session           VARCHAR2(100 BYTE) NOT NULL,
    arcs_fechacambio       DATE NOT NULL,
    arcs_procesoauditoria  VARCHAR2(120 BYTE),
    arcs_publico           NUMBER(1),
    arcs_descripcion       VARCHAR2(100 BYTE),
    arcs_fechasoat         DATE
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
    LOB ( arcs_archivo ) STORE AS (
        TABLESPACE tramitedat
        STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
        CHUNK 8192
        RETENTION
        ENABLE STORAGE IN ROW
        NOCACHE LOGGING
    );

CREATE UNIQUE INDEX tramite.uk_archivo_session ON
    tramite.archivo_session (
        arcs_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.archivo_session
    ADD CONSTRAINT uk_archivo_session UNIQUE ( arcs_id )
        USING INDEX tramite.uk_archivo_session;

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_SOLICITUD (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_TRAM_ID IN SOLICITUD.TRAM_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_FECHACAMBIO IN SOLICITUD.SOLI_FECHACAMBIO%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_SOLI_FECHA IN SOLICITUD.SOLI_FECHA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOLI_RADICADO IN SOLICITUD.SOLI_RADICADO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLICITUD(
ESSO_ID,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_RADICADO
)
VALUES (
P_ESSO_ID,
P_TRAM_ID,
P_SOLI_REGISTRADOPOR,
P_SOLI_FECHACAMBIO,
P_SOLI_ACTIVARIMPRESION,
P_SOLI_ACTIVO,
P_SOLI_PROCESOAUDITORIA,
P_SOLI_FECHA,
P_PERS_ID,
P_SOLI_RADICADO
);

SELECT S_SOLI_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE TABLE tramite.tramiteestadosolicitud (
    tram_id                NUMBER(30) NOT NULL,
    esso_id                NUMBER(30) NOT NULL,
    tres_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    tres_fechacambio       DATE NOT NULL,
    tres_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    timeout                NUMBER,
    pers_id                VARCHAR2(10 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.tramiteestadosolicitud IS
    'Almacena los estados que pueden adoptar las solicitudes de tramites';

COMMENT ON COLUMN tramite.tramiteestadosolicitud.tram_id IS
    'ALMACENA EL IDENTIFICADOR DE TRAMITE';

COMMENT ON COLUMN tramite.tramiteestadosolicitud.esso_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA ESTADO SOLICITUD';

COMMENT ON COLUMN tramite.tramiteestadosolicitud.tres_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tramiteestadosolicitud.tres_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tramiteestadosolicitud.tres_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_tres ON
    tramite.tramiteestadosolicitud (
        tram_id
    ASC,
        esso_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tramiteestadosolicitud
    ADD CONSTRAINT pk_tres PRIMARY KEY ( tram_id,
                                         esso_id )
        USING INDEX tramite.pk_tres;

CREATE TABLE tramite.archivo (
    arch_id                NUMBER(30) NOT NULL,
    arch_extension         VARCHAR2(10 BYTE),
    arch_nombre            VARCHAR2(100 BYTE) NOT NULL,
    arch_archivo           BLOB,
    arch_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    arch_fechacambio       DATE NOT NULL,
    arch_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    arch_descripcion       VARCHAR2(500 BYTE),
    arch_doc               VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOB ( arch_archivo ) STORE AS (
            TABLESPACE tramitedat
            STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
            CHUNK 8192
            RETENTION
            ENABLE STORAGE IN ROW
            NOCACHE LOGGING
        )
    ENABLE ROW MOVEMENT;

CREATE UNIQUE INDEX tramite.pk_arch ON
    tramite.archivo (
        arch_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.archivo
    ADD CONSTRAINT pk_arch PRIMARY KEY ( arch_id )
        USING INDEX tramite.pk_arch;

CREATE TABLE tramite.solicitudestacionarch (
    arch_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    sope_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    sope_fechacambio       DATE NOT NULL,
    sope_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    sope_id                NUMBER(8),
    arch_publico           NUMBER(1) DEFAULT 0,
    arch_tipo              NUMBER(*, 0),
    arch_estado            NUMBER(*, 0),
    arch_departamento      VARCHAR2(300 BYTE),
    arch_municipio         VARCHAR2(300 BYTE),
    arch_fechaexpedicion   DATE,
    arch_tiposuelo         VARCHAR2(300 BYTE),
    arch_profesion         VARCHAR2(300 BYTE),
    arch_entidad           VARCHAR2(300 BYTE),
    arch_profesional       VARCHAR2(300 BYTE),
    arch_activo            NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.mods (
    soli_id          NUMBER(30),
    mod_desccambio   VARCHAR2(500 BYTE),
    mod_nomcambio    VARCHAR2(50 BYTE),
    mod_fechacambio  DATE,
    pers_id          NUMBER(20) DEFAULT 0
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

GRANT SELECT ON tramite.mods TO tramite_consulta;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_CONCEPTO_ESTACION (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOES_CODIGOVIA IN SOLICITUDESTACION.SOES_CODIGOVIA%TYPE,
P_SOES_INICIO_PR IN SOLICITUDESTACION.SOES_INICIO_PR%TYPE,
P_SOES_FIN_PR IN SOLICITUDESTACION.SOES_FIN_PR%TYPE,
P_DEPA_ID IN SOLICITUDESTACION.DEPA_ID%TYPE,
P_MUNI_ID IN SOLICITUDESTACION.MUNI_ID%TYPE,
P_SOES_COSTADO IN SOLICITUDESTACION.SOES_COSTADO%TYPE,
P_SOES_TIPOPREDIO IN SOLICITUDESTACION.SOES_TIPOPREDIO%TYPE,
P_SOES_PROYECTO IN SOLICITUDESTACION.SOES_PROYECTO%TYPE,
P_SOES_PROPIETARIONOMBRE IN SOLICITUDESTACION.SOES_PROPIETARIONOMBRE%TYPE,
P_SOES_PROPIETARIOCEDULA IN SOLICITUDESTACION.SOES_PROPIETARIOCEDULA%TYPE,
P_SOES_PROPIETARIOTELEFONO IN SOLICITUDESTACION.SOES_PROPIETARIOTELEFONO%TYPE,
P_SOES_PROPIETARIOCELULAR IN SOLICITUDESTACION.SOES_PROPIETARIOCELULAR%TYPE,
P_SOES_PROPIETARIODIRECCION IN SOLICITUDESTACION.SOES_PROPIETARIODIRECCION%TYPE,
P_SOES_PROPIETARIOCORREO IN SOLICITUDESTACION.SOES_PROPIETARIOCORREO%TYPE,
P_SOES_NUMEROMATRICULA IN SOLICITUDESTACION.SOES_NUMEROMATRICULA%TYPE,
P_SOES_CEDULACATASTRAL IN SOLICITUDESTACION.SOES_CEDULACATASTRAL%TYPE,
P_SOES_CIRCULOCATASTRAL IN SOLICITUDESTACION.SOES_CIRCULOCATASTRAL%TYPE,
P_DEPA_ID_CATASTRAL IN SOLICITUDESTACION.DEPA_ID_CATASTRAL%TYPE,
P_MUNI_ID_CATASTRAL  IN SOLICITUDESTACION.MUNI_ID_CATASTRAL%TYPE,
P_SOES_ESPROPIETARIO  IN SOLICITUDESTACION.SOES_ESPROPIETARIO%TYPE,
P_SOES_APODERADONOMBRE IN SOLICITUDESTACION.SOES_APODERADONOMBRE%TYPE,
P_SOES_APODERADOCEDULA IN SOLICITUDESTACION.SOES_APODERADOCEDULA%TYPE,
P_SOES_APODERADOTELEFONO IN SOLICITUDESTACION.SOES_APODERADOTELEFONO%TYPE,
P_SOES_APODERADOCELULAR IN SOLICITUDESTACION.SOES_APODERADOCELULAR%TYPE,
P_SOES_APODERADODIRECCION IN SOLICITUDESTACION.SOES_APODERADODIRECCION%TYPE,
P_SOES_APODERADOCORREO IN SOLICITUDESTACION.SOES_APODERADOCORREO%TYPE,
P_SESSION IN VARCHAR,
P_RETORNO OUT VARCHAR,
P_ERROR OUT VARCHAR
)
AS
NUMERO_REGISTROS NUMBER;
NUMRADICADO INT;
VALMAX VARCHAR(100);
COES VARCHAR(100);
SOLI_ID NUMBER;
BEGIN
/*Diciembre 12 de 2018 
Insertar una solicitud para concepto tecnico de estaciones de servicio, 

*/
    P_ERROR := '';
    
    SELECT COUNT(*) INTO NUMERO_REGISTROS FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION;
    IF NUMERO_REGISTROS < 1 THEN
        P_ERROR := 'No existen archivos adjuntos para soportar la solicitud';
        RAISE VALUE_ERROR; 
    END IF;
    /*Determinar el numero de radicado*/
    SELECT MAX ( SUBSTR ( SOLI_RADICADO, 6, 11)) INTO VALMAX FROM SOLICITUD WHERE SOLI_RADICADO LIKE '%COES_%';
    
    
    IF VALMAX IS NULL THEN
        VALMAX := '1';
    END IF; 
    SELECT TO_NUMBER(VALMAX, '999999999') INTO NUMRADICADO FROM DUAL;
    NUMRADICADO := NUMRADICADO+1;
    SELECT 'COES_' || SUBSTR(TO_CHAR(NUMRADICADO,'00000009999999'),-6,6) INTO COES FROM DUAL;
    P_RETORNO := COES;
    /*Se ralizar el registro en el la tabla de solicitud t*/
    PR_TRAMITE_I_SOLICITUD (P_ESSO_ID,42,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_ACTIVARIMPRESION,P_SOLI_ACTIVO,P_SOLI_PROCESOAUDITORIA,SYSDATE,P_PERS_ID,COES,SOLI_ID);
    update solicitud set soli_asignado = (select pers_id from tramiteestadosolicitud where esso_id = P_ESSO_ID and tram_id = 42),SOLI_DESCCAMBIO='Registro inicial del usuario' where solicitud.soli_id = SOLI_ID; 
    /*sE INSERTA EN LA TABLA DE ESTACIONES*/
    INSERT INTO TRAMITE.SOLICITUDESTACION (SOLI_ID, SOES_CODIGOVIA, SOES_INICIO_PR,SOES_FIN_PR, 
        SOES_DESCRIPCION,DEPA_ID,MUNI_ID,SOES_COSTADO,SOES_TIPOPREDIO,
        SOES_PROYECTO,SOES_PROPIETARIONOMBRE,SOES_PROPIETARIOCEDULA,SOES_PROPIETARIOTELEFONO,
        SOES_PROPIETARIOCELULAR,SOES_PROPIETARIODIRECCION,SOES_PROPIETARIOCORREO,
        SOES_NUMEROMATRICULA,SOES_CEDULACATASTRAL,SOES_CIRCULOCATASTRAL,DEPA_ID_CATASTRAL,MUNI_ID_CATASTRAL, SOES_ESPROPIETARIO, SOES_APODERADONOMBRE, SOES_APODERADOCEDULA,
        SOES_APODERADOTELEFONO, SOES_APODERADOCELULAR, SOES_APODERADODIRECCION, SOES_APODERADOCORREO
    ) 
    VALUES ( SOLI_ID,P_SOES_CODIGOVIA, P_SOES_INICIO_PR,P_SOES_FIN_PR,'Registro inicial del usuario',P_DEPA_ID,P_MUNI_ID,P_SOES_COSTADO,P_SOES_TIPOPREDIO,
          P_SOES_PROYECTO,P_SOES_PROPIETARIONOMBRE,P_SOES_PROPIETARIOCEDULA,P_SOES_PROPIETARIOTELEFONO,
          P_SOES_PROPIETARIOCELULAR,P_SOES_PROPIETARIODIRECCION,P_SOES_PROPIETARIOCORREO,
          P_SOES_NUMEROMATRICULA,P_SOES_CEDULACATASTRAL,P_SOES_CIRCULOCATASTRAL,P_DEPA_ID_CATASTRAL,P_MUNI_ID_CATASTRAL, P_SOES_ESPROPIETARIO,P_SOES_APODERADONOMBRE, P_SOES_APODERADOCEDULA,
          P_SOES_APODERADOTELEFONO, P_SOES_APODERADOCELULAR, P_SOES_APODERADODIRECCION, P_SOES_APODERADOCORREO
           );
    
    /*Transferir los archivos cargados*/
    
    insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_fechacambio,arch_procesoauditoria,arch_descripcion,arch_registradopor)
    select arcs_extension,arcs_nombre,arcs_archivo,sysdate,arcs_descripcion,arcs_session,7162   from archivo_session where arcs_session = P_SESSION;
    insert into SOLICITUDESTACIONARCH(arch_id,soli_id,sope_registradopor,sope_fechacambio,sope_procesoauditoria,arch_tipo,arch_estado)
    select arch_id,SOLI_ID,7162,sysdate,P_SOLI_PROCESOAUDITORIA,arch_procesoauditoria,1 from archivo where arch_descripcion = P_SESSION;
    
    /*Insertar un registro del movimiento */
    INSERT INTO MODS(SOLI_ID,MOD_DESCCAMBIO,MOD_NOMCAMBIO,MOD_FECHACAMBIO)  VALUES(SOLI_ID,'Registro inicial del usuario','INVITRAMITES',sysdate);
    
    /*Limpiar el archivo de session*/
    delete  from archivo_session  where arcs_session =  P_SESSION;
    delete  from archivo_session  where arcs_fechacambio < (sysdate-1);
    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.solicitudevento (
    soli_id                NUMBER(30) NOT NULL,
    soev_descripcion       VARCHAR2(500 BYTE) NOT NULL,
    soev_fechainicio       DATE NOT NULL,
    soev_fechafin          DATE NOT NULL,
    soev_nombreevento      VARCHAR2(500 BYTE),
    soev_organizacion      VARCHAR2(2500 BYTE),
    soev_descripcionetapa  VARCHAR2(2500 BYTE),
    soev_esdeportivo       NUMBER(*, 0),
    soev_esciclismo        NUMBER(*, 0),
    soev_esprofesional     NUMBER(*, 0),
    sevt_id                VARCHAR2(20 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudevento_pk ON
    tramite.solicitudevento (
        soli_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudevento
    ADD CONSTRAINT solicitudevento_pk PRIMARY KEY ( soli_id )
        USING INDEX tramite.solicitudevento_pk;

CREATE TABLE tramite.solicitudeventoarchivo (
    arch_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    soev_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    soev_fechacambio       DATE NOT NULL,
    soev_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    arch_publico           NUMBER(1) DEFAULT 0,
    arch_tipo              NUMBER(*, 0),
    arch_estado            NUMBER(*, 0),
    sear_id                NUMBER(*, 0) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudeventoarchivo_pk ON
    tramite.solicitudeventoarchivo (
        sear_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudeventoarchivo
    ADD CONSTRAINT solicitudeventoarchivo_pk PRIMARY KEY ( sear_id )
        USING INDEX tramite.solicitudeventoarchivo_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_EVENTO (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOEV_DESCRIPCION      IN SOLICITUDEVENTO.SOEV_DESCRIPCION%TYPE,
P_SOEV_FECHAINICIO      IN SOLICITUDEVENTO.SOEV_FECHAINICIO%TYPE,
P_SOEV_FECHAFIN         IN SOLICITUDEVENTO.SOEV_FECHAFIN%TYPE,
P_SEVT_ID               IN SOLICITUDEVENTO.SEVT_ID%TYPE,
P_SOEV_NOMBREEVENTO     IN SOLICITUDEVENTO.SOEV_NOMBREEVENTO%TYPE,
P_SOEV_ORGANIZACION     IN SOLICITUDEVENTO.SOEV_ORGANIZACION%TYPE,
P_SOEV_DESCRIPCIONETAPA IN SOLICITUDEVENTO.SOEV_DESCRIPCIONETAPA%TYPE,
P_SOEV_ESDEPORTIVO      IN SOLICITUDEVENTO.SOEV_ESDEPORTIVO%TYPE,
P_SOEV_ESCICLISMO       IN SOLICITUDEVENTO.SOEV_ESCICLISMO%TYPE,
P_SOEV_ESPROFESIONAL    IN SOLICITUDEVENTO.SOEV_ESPROFESIONAL%TYPE,
P_SESSION IN VARCHAR,
P_SOLI_ID OUT NUMBER,
P_RETORNO OUT VARCHAR,
P_ERROR OUT VARCHAR
)
AS
NUMERO_REGISTROS NUMBER;
NUMRADICADO INT;
VALMAX VARCHAR(100);
SOEV VARCHAR(100);
SOLI_ID NUMBER;
BEGIN
/*Diciembre 12 de 2018 
Insertar una solicitud para concepto tecnico de estaciones de servicio, 

*/
    P_ERROR := '';
    
    SELECT COUNT(*) INTO NUMERO_REGISTROS FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION;
    IF NUMERO_REGISTROS < 1 THEN
        P_ERROR := 'No existen archivos adjuntos para soportar la solicitud';
        RAISE VALUE_ERROR; 
    END IF;
    /*Determinar el numero de radicado*/
    SELECT MAX ( SUBSTR ( SOLI_RADICADO, 6, 11)) INTO VALMAX FROM SOLICITUD WHERE SOLI_RADICADO LIKE '%COES_%';
    
    
    IF VALMAX IS NULL THEN
        VALMAX := '1';
    END IF; 
    SELECT TO_NUMBER(VALMAX, '999999999') INTO NUMRADICADO FROM DUAL;
    NUMRADICADO := NUMRADICADO+1;
    SELECT 'SOEV_' || SUBSTR(TO_CHAR(NUMRADICADO,'00000009999999'),-6,6) INTO SOEV FROM DUAL;
    P_RETORNO := SOEV;
    /*Se ralizar el registro en el la tabla de solicitud t*/
    
    PR_TRAMITE_I_SOLICITUD (P_ESSO_ID,3,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_ACTIVARIMPRESION,P_SOLI_ACTIVO,P_SOLI_PROCESOAUDITORIA,SYSDATE,P_PERS_ID,SOEV,SOLI_ID);
    update solicitud set soli_asignado = (select pers_id from tramiteestadosolicitud where esso_id = P_ESSO_ID and tram_id = 42),SOLI_DESCCAMBIO='Registro inicial del usuario' where solicitud.soli_id = SOLI_ID; 
    /*sE INSERTA EN LA TABLA DE EVENTOS*/
    P_SOLI_ID := SOLI_ID;
    INSERT INTO SOLICITUDEVENTO(SOLI_ID,SOEV_DESCRIPCION,SOEV_FECHAINICIO,      
           SOEV_FECHAFIN,SEVT_ID,SOEV_NOMBREEVENTO,     
           SOEV_ORGANIZACION,SOEV_DESCRIPCIONETAPA,SOEV_ESDEPORTIVO,      
           SOEV_ESCICLISMO,SOEV_ESPROFESIONAL)
    VALUES(SOLI_ID,P_SOEV_DESCRIPCION,P_SOEV_FECHAINICIO,      
           P_SOEV_FECHAFIN,P_SEVT_ID,P_SOEV_NOMBREEVENTO,     
           P_SOEV_ORGANIZACION,P_SOEV_DESCRIPCIONETAPA,P_SOEV_ESDEPORTIVO,      
           P_SOEV_ESCICLISMO,P_SOEV_ESPROFESIONAL);
    /*Transferir los archivos cargados*/
    
    INSERT INTO archivo(arch_extension,arch_nombre,arch_archivo,arch_fechacambio,arch_procesoauditoria,arch_descripcion,arch_registradopor)
    SELECT arcs_extension,arcs_nombre,arcs_archivo,sysdate,arcs_descripcion,arcs_session,7162   from archivo_session where arcs_session = P_SESSION;
    
    INSERT INTO SOLICITUDEVENTOARCHIVO(arch_id,soli_id,soev_registradopor,soev_fechacambio,soev_procesoauditoria,arch_tipo,arch_estado)
    SELECT arch_id,SOLI_ID,7162,sysdate,P_SOLI_PROCESOAUDITORIA,arch_procesoauditoria,1 from archivo where arch_descripcion = P_SESSION;
    
    /*Insertar un registro del movimiento */
    INSERT INTO MODS(SOLI_ID,MOD_DESCCAMBIO,MOD_NOMCAMBIO,MOD_FECHACAMBIO)  VALUES(SOLI_ID,'Registro inicial del usuario','INVITRAMITES',sysdate);
    
    /*Limpiar el archivo de session*/
    DELETE  FROM  archivo_session  where arcs_session =  P_SESSION;
    DELETE  FROM  archivo_session  where arcs_fechacambio < (sysdate-1);
    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.solicitudeventoetapa (
    soli_id      NUMBER(30) NOT NULL,
    seet_numero  NUMBER(*, 0) NOT NULL,
    seet_fecha   DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudeventoetapa_pk ON
    tramite.solicitudeventoetapa (
        soli_id
    ASC,
        seet_numero
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudeventoetapa
    ADD CONSTRAINT solicitudeventoetapa_pk PRIMARY KEY ( soli_id,
                                                         seet_numero )
        USING INDEX tramite.solicitudeventoetapa_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_EVENTO_ETAPA (
P_SOLI_ID               IN SOLICITUDEVENTOETAPA.SOLI_ID%TYPE,
P_SEVT_NUMERO           IN SOLICITUDEVENTOETAPA.SEET_NUMERO%TYPE,
P_SEVT_FECHA            IN SOLICITUDEVENTOETAPA.SEET_FECHA%TYPE,
P_ERROR OUT VARCHAR
)
AS
BEGIN
    P_ERROR := '';
    INSERT INTO SOLICITUDEVENTOETAPA (SOLI_ID, SEET_NUMERO, SEET_FECHA) 
    VALUES ( P_SOLI_ID, P_SEVT_NUMERO, P_SEVT_FECHA);    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.solicitudeventoetapavia (
    soli_id         NUMBER(30) NOT NULL,
    seet_numero     NUMBER(*, 0) NOT NULL,
    sevi_id         NUMBER(30) NOT NULL,
    sevi_codigovia  VARCHAR2(30 BYTE) NOT NULL,
    sevi_prini      NUMBER(5) NOT NULL,
    sevi_disini     NUMBER(5) NOT NULL,
    sevi_prfin      NUMBER(5) NOT NULL,
    sevi_disfin     NUMBER(5) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudeventoetapavia_pk ON
    tramite.solicitudeventoetapavia (
        sevi_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudeventoetapavia
    ADD CONSTRAINT solicitudeventoetapavia_pk PRIMARY KEY ( sevi_id )
        USING INDEX tramite.solicitudeventoetapavia_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_EVENTO_ETAPA_VIA (
P_SOLI_ID               IN SOLICITUDEVENTOETAPAVIA.SOLI_ID%TYPE,
P_NUMERO           IN SOLICITUDEVENTOETAPAVIA.SEET_NUMERO%TYPE,
P_CODIGOVIA    IN SOLICITUDEVENTOETAPAVIA.SEVI_CODIGOVIA%TYPE,
P_PRINI   IN SOLICITUDEVENTOETAPAVIA.SEVI_PRINI%TYPE,
P_DISINI   IN SOLICITUDEVENTOETAPAVIA.SEVI_DISINI%TYPE,
P_PRFIN   IN SOLICITUDEVENTOETAPAVIA.SEVI_PRFIN%TYPE,
P_DISFIN   IN SOLICITUDEVENTOETAPAVIA.SEVI_DISFIN%TYPE,
P_ERROR OUT VARCHAR
)
AS
BEGIN
    P_ERROR := '';
    INSERT INTO SOLICITUDEVENTOETAPAVIA (SOLI_ID, SEET_NUMERO, 
        SEVI_CODIGOVIA, SEVI_PRINI, SEVI_DISINI,SEVI_PRFIN, SEVI_DISFIN)
    VALUES ( P_SOLI_ID, P_NUMERO,P_CODIGOVIA,P_PRINI,P_DISINI,P_PRFIN,P_DISFIN );
    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.solicitudcarga (
    soli_id                NUMBER(30) NOT NULL,
    camo_id                NUMBER(30) NOT NULL,
    soca_fechaorigen       DATE NOT NULL,
    soca_fechadestino      DATE,
    soca_diasmovilizacion  VARCHAR2(10 BYTE) NOT NULL,
    soca_numeroevasion     VARCHAR2(50 BYTE),
    soca_funcionario       VARCHAR2(100 BYTE),
    soca_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    soca_fechacambio       DATE NOT NULL,
    soca_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    vehi_id                NUMBER(30) NOT NULL,
    soca_seguridad         VARCHAR2(20 BYTE),
    soca_aprobado          VARCHAR2(2 BYTE),
    charge                 VARCHAR2(200 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudcarga IS
    'Almacena las solicitudes de tramites de carga extra-dimensionada';

COMMENT ON COLUMN tramite.solicitudcarga.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudcarga.camo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.solicitudcarga.soca_fechaorigen IS
    'ALMACENA LA FECHA ORIGEN';

COMMENT ON COLUMN tramite.solicitudcarga.soca_fechadestino IS
    'ALMACENA LA FECHA DESTINO';

COMMENT ON COLUMN tramite.solicitudcarga.soca_diasmovilizacion IS
    'ALMACENA LOS DIAS DE MOVILIZACION';

COMMENT ON COLUMN tramite.solicitudcarga.soca_numeroevasion IS
    'ALMACENA EL NUMERO DE EVACION';

COMMENT ON COLUMN tramite.solicitudcarga.soca_funcionario IS
    'ALMACENA EL NOMBRE DEL FUNCIONARIO';

COMMENT ON COLUMN tramite.solicitudcarga.soca_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudcarga.soca_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcarga.soca_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcarga.vehi_id IS
    'ALMACENA EL IDENTIFICADOR DEL VEHICULO';

CREATE UNIQUE INDEX tramite.pk_soca ON
    tramite.solicitudcarga (
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.solicitudcarga TO tramite_consulta;

ALTER TABLE tramite.solicitudcarga
    ADD CONSTRAINT pk_soca PRIMARY KEY ( soli_id )
        USING INDEX tramite.pk_soca;

CREATE TABLE tramite.consignacion (
    cons_id                NUMBER(30) NOT NULL,
    banc_id                NUMBER(30) NOT NULL,
    muni_id                VARCHAR2(30 BYTE) NOT NULL,
    depa_id                VARCHAR2(30 BYTE) NOT NULL,
    cons_valor             VARCHAR2(50 BYTE) NOT NULL,
    cons_fecha             DATE NOT NULL,
    cons_numero            VARCHAR2(50 BYTE) NOT NULL,
    cons_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    cons_fechacambio       DATE NOT NULL,
    cons_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    cons_comproingreso     VARCHAR2(100 BYTE),
    cons_concepto          VARCHAR2(40 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.consignacion IS
    'Almacena los datos de la consignacion del pago del tramite de carga extra-dimensionada';

COMMENT ON COLUMN tramite.consignacion.cons_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.consignacion.banc_id IS
    'ALMACENA EL IDENTIFICADOR DEL BANCO';

COMMENT ON COLUMN tramite.consignacion.muni_id IS
    'ALMACENA EL IDENTIFICADOR DLE MUNICIPIO';

COMMENT ON COLUMN tramite.consignacion.depa_id IS
    'ALMACENA EL IDENTIFICADOR DEL DEPARTAMENTO';

COMMENT ON COLUMN tramite.consignacion.cons_valor IS
    'ALMACENA EL VALOR DE LA CONSIGNACION';

COMMENT ON COLUMN tramite.consignacion.cons_fecha IS
    'ALMACENA LA FECHA DELA CONSIGNACION';

COMMENT ON COLUMN tramite.consignacion.cons_numero IS
    'ALMACENA EL NUMERIO DE LA CONSIGNACION';

COMMENT ON COLUMN tramite.consignacion.cons_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.consignacion.cons_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.consignacion.cons_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.consignacion.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE SOLICITUD';

CREATE UNIQUE INDEX tramite.pk_cons ON
    tramite.consignacion (
        cons_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.consignacion
    ADD CONSTRAINT pk_cons PRIMARY KEY ( cons_id )
        USING INDEX tramite.pk_cons;

CREATE TABLE tramite.cargamovilizada (
    camo_id                     NUMBER(30) NOT NULL,
    camo_ancho                  VARCHAR2(100 BYTE) NOT NULL,
    camo_alto                   VARCHAR2(100 BYTE) NOT NULL,
    camo_longitudsobresaliente  VARCHAR2(100 BYTE) NOT NULL,
    camo_registradopor          VARCHAR2(30 BYTE) NOT NULL,
    camo_fechacambio            DATE NOT NULL,
    camo_procesoauditoria       VARCHAR2(300 BYTE) NOT NULL,
    camo_peso                   VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.cargamovilizada IS
    'Almacena las caracteristicas de la carga movilizada en la solicitud de carga extra-dimensionada';

COMMENT ON COLUMN tramite.cargamovilizada.camo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.cargamovilizada.camo_ancho IS
    'ALMACENA EL ANCHO DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.cargamovilizada.camo_alto IS
    'ALMACENA EL ALTO DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.cargamovilizada.camo_longitudsobresaliente IS
    'ALMACENA LA LONGITUD DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.cargamovilizada.camo_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.cargamovilizada.camo_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.cargamovilizada.camo_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_camo ON
    tramite.cargamovilizada (
        camo_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.cargamovilizada
    ADD CONSTRAINT pk_camo PRIMARY KEY ( camo_id )
        USING INDEX tramite.pk_camo;

CREATE TABLE tramite.parametrizacion (
    para_id                         NUMBER(30) NOT NULL,
    para_pagoelectronico            VARCHAR2(1 BYTE) NOT NULL,
    para_impresionrecibopag         VARCHAR2(1 BYTE) NOT NULL,
    para_solitransportecarg         VARCHAR2(1 BYTE) NOT NULL,
    para_soliusozonacarrete         VARCHAR2(1 BYTE) NOT NULL,
    para_solicierrevia              VARCHAR2(1 BYTE) NOT NULL,
    para_solipazysalvo              VARCHAR2(1 BYTE) NOT NULL,
    para_registradopor              VARCHAR2(30 BYTE) NOT NULL,
    para_fechacambio                DATE NOT NULL,
    para_procesoauditoria           VARCHAR2(300 BYTE) NOT NULL,
    para_correoremitente            VARCHAR2(100 BYTE) NOT NULL,
    para_ancho                      VARCHAR2(100 BYTE),
    para_alto                       VARCHAR2(100 BYTE),
    para_longitudsobresaliente      VARCHAR2(100 BYTE),
    para_leyenda                    VARCHAR2(4000 BYTE),
    para_redvial                    VARCHAR2(100 BYTE),
    para_urlaplicativo              VARCHAR2(500 BYTE) NOT NULL,
    para_esfitramitecarga           NUMBER(30),
    para_peso                       VARCHAR2(100 BYTE),
    para_cargo                      VARCHAR2(100 BYTE),
    para_funcionario                VARCHAR2(100 BYTE),
    para_valordiacarga              VARCHAR2(20 BYTE),
    para_mensaje                    VARCHAR2(1000 BYTE),
    para_correofuncionario          VARCHAR2(100 BYTE),
    para_solipermisoespecial        VARCHAR2(1 BYTE),
    para_encuesta_usuario           VARCHAR2(1 BYTE) DEFAULT 'N',
    para_estu_pavimentos            NUMBER(*, 0),
    para_estu_puentes               NUMBER(*, 0),
    para_estu_transito              NUMBER(*, 0),
    para_autorizacion_notificacion  VARCHAR2(1500 BYTE),
    para_pers_id_invias             NUMBER,
    para_pers_id_ani                NUMBER
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_pagoelectronico CHECK ( para_pagoelectronico IN ( 'N', 'S' ) );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_impresionrecibopag CHECK ( para_impresionrecibopag IN ( 'N', 'S' ) );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_solitransportecarg CHECK ( para_solitransportecarg IN ( 'N', 'S' ) );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_soliusozonacarrete CHECK ( para_soliusozonacarrete IN ( 'N', 'S' ) );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_solicierrevia CHECK ( para_solicierrevia IN ( 'N', 'S' ) );

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT ck_para_solipazysalvo CHECK ( para_solipazysalvo IN ( 'N', 'S' ) );

COMMENT ON TABLE tramite.parametrizacion IS
    'Almacena los valores parametrizados para que el aplicativo funcione correctamente';

COMMENT ON COLUMN tramite.parametrizacion.para_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.parametrizacion.para_pagoelectronico IS
    'ALMACENA SI SE ACTIVA O NO EL PAGO ELECTRONICO S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_impresionrecibopag IS
    'ALMACENA SI SE ACTIVA O NO EL PAGO DEL RECIBO DE PAGO, S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_solitransportecarg IS
    'ALMACENA SI SE ACTIVA O NO LA SOLICITUD DE TRANSPORTE DE CARGA, S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_soliusozonacarrete IS
    'ALMACENA SI SE ACTIVA O NO LA SOLICITUD DE ZONA DE CARRETERA, S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_solicierrevia IS
    'ALMACENA SI SE ACTIVA O NO LA SOLICITUD DE CIERRE DE VIA, S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_solipazysalvo IS
    'ALMACENA SI SE ACTIVA O NO LA SOLICITUD DE PAZ Y SALVO, S=SI Y N=NO';

COMMENT ON COLUMN tramite.parametrizacion.para_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.parametrizacion.para_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.parametrizacion.para_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.parametrizacion.para_correoremitente IS
    'ALMACENA EL CORREO DEL REMITENTE DE INVIAS HACIA EL USUARIO QUE QUIERE SER CLIENTE DEL MODULO TRAMITE';

COMMENT ON COLUMN tramite.parametrizacion.para_ancho IS
    'ALMACENA EL ANCHO DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.parametrizacion.para_alto IS
    'ALMACENA EL ALTO DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.parametrizacion.para_longitudsobresaliente IS
    'ALMACENA LA LONGITUDSO BRESALIENTE DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.parametrizacion.para_leyenda IS
    'ALMACENA LA LEYENDA DE LA SOLICITUD DE PAZ Y SALVO';

COMMENT ON COLUMN tramite.parametrizacion.para_redvial IS
    'ALMACENA EL TEXTO RED VIAL NACIONAL PARA LA MOVILIZACION DE LA CARGA';

COMMENT ON COLUMN tramite.parametrizacion.para_urlaplicativo IS
    'ALMACENA LA URL DEL APLICATIVO';

COMMENT ON COLUMN tramite.parametrizacion.para_esfitramitecarga IS
    'ALMACENA EL ESTADO FINAL DE LA SOLICITD TRAMITE CARGA';

COMMENT ON COLUMN tramite.parametrizacion.para_encuesta_usuario IS
    'PARAMETRO PARA DEFINIR SI ESTA ACTIVA LA ENCUESTA';

CREATE UNIQUE INDEX tramite.pk_para ON
    tramite.parametrizacion (
        para_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.parametrizacion
    ADD CONSTRAINT pk_para PRIMARY KEY ( para_id )
        USING INDEX tramite.pk_para;

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_CARGAMOVILIZADA (
P_CAMO_ANCHO IN CARGAMOVILIZADA.CAMO_ANCHO%TYPE,
P_CAMO_ALTO IN CARGAMOVILIZADA.CAMO_ALTO%TYPE,
P_CAMO_LONGITUDSOBRESALIENTE IN CARGAMOVILIZADA.CAMO_LONGITUDSOBRESALIENTE%TYPE,
P_CAMO_REGISTRADOPOR IN CARGAMOVILIZADA.CAMO_REGISTRADOPOR%TYPE,
P_CAMO_FECHACAMBIO IN CARGAMOVILIZADA.CAMO_FECHACAMBIO%TYPE,
P_CAMO_PROCESOAUDITORIA IN CARGAMOVILIZADA.CAMO_PROCESOAUDITORIA%TYPE,
P_CAMO_PESO IN CARGAMOVILIZADA.CAMO_PESO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.CARGAMOVILIZADA(
CAMO_ANCHO,
CAMO_ALTO,
CAMO_LONGITUDSOBRESALIENTE,
CAMO_REGISTRADOPOR,
CAMO_FECHACAMBIO,
CAMO_PROCESOAUDITORIA,
CAMO_PESO
)
VALUES (
P_CAMO_ANCHO,
P_CAMO_ALTO,
P_CAMO_LONGITUDSOBRESALIENTE,
P_CAMO_REGISTRADOPOR,
P_CAMO_FECHACAMBIO,
P_CAMO_PROCESOAUDITORIA,
P_CAMO_PESO
);

SELECT S_CAMO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_SOLICITUDCARGA(
 P_SOLI_ID                  IN SOLICITUDCARGA.SOLI_ID%TYPE,
 P_CAMO_ID                  IN SOLICITUDCARGA.CAMO_ID%TYPE,               
 P_SOCA_FECHAORIGEN         IN SOLICITUDCARGA.SOCA_FECHAORIGEN%TYPE,      
 P_SOCA_FECHADESTINO        IN SOLICITUDCARGA.SOCA_FECHADESTINO%TYPE,     
 P_SOCA_DIASMOVILIZACION    IN SOLICITUDCARGA.SOCA_DIASMOVILIZACION%TYPE, 
 P_SOCA_NUMEROEVASION       IN SOLICITUDCARGA.SOCA_NUMEROEVASION%TYPE,    
 P_SOCA_FUNCIONARIO         IN SOLICITUDCARGA.SOCA_FUNCIONARIO%TYPE,      
 P_SOCA_REGISTRADOPOR       IN SOLICITUDCARGA.SOCA_REGISTRADOPOR%TYPE,    
 P_SOCA_FECHACAMBIO         IN SOLICITUDCARGA.SOCA_FECHACAMBIO%TYPE,      
 P_SOCA_PROCESOAUDITORIA    IN SOLICITUDCARGA.SOCA_PROCESOAUDITORIA%TYPE, 
 P_PERS_ID                  IN SOLICITUDCARGA.PERS_ID%TYPE,               
 P_VEHI_ID                  IN SOLICITUDCARGA.VEHI_ID%TYPE,               
 P_SOCA_SEGURIDAD           IN SOLICITUDCARGA.SOCA_SEGURIDAD%TYPE,        
 P_SOCA_APROBADO            IN SOLICITUDCARGA.SOCA_APROBADO%TYPE,         
 P_CHARGE                   IN SOLICITUDCARGA.CHARGE%TYPE
)
AS
E_ERROR EXCEPTION;
BEGIN
INSERT INTO tramite.SOLICITUDCARGA(
SOLI_ID,
CAMO_ID,
SOCA_FECHAORIGEN,
SOCA_FECHADESTINO,
SOCA_DIASMOVILIZACION,
SOCA_NUMEROEVASION,
SOCA_FUNCIONARIO,
SOCA_REGISTRADOPOR,
SOCA_FECHACAMBIO,
SOCA_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
SOCA_SEGURIDAD,
SOCA_APROBADO,
CHARGE
)
VALUES (
P_SOLI_ID,
P_CAMO_ID,
P_SOCA_FECHAORIGEN,
P_SOCA_FECHADESTINO,
P_SOCA_DIASMOVILIZACION,
P_SOCA_NUMEROEVASION,
P_SOCA_FUNCIONARIO,
P_SOCA_REGISTRADOPOR,
P_SOCA_FECHACAMBIO,
P_SOCA_PROCESOAUDITORIA,
P_PERS_ID,
P_VEHI_ID,
P_SOCA_SEGURIDAD,
P_SOCA_APROBADO,
P_CHARGE
);

END;
/

CREATE TABLE tramite.solicitudcargaremolque (
    remo_id                NUMBER(30) NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    socr_fechacambio       DATE NOT NULL,
    socr_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    socr_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudcargaremolque IS
    'Almacena los remolques incluidos en la solicitud de carga-extra-dimensionada';

COMMENT ON COLUMN tramite.solicitudcargaremolque.remo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA REMOLQUE';

COMMENT ON COLUMN tramite.solicitudcargaremolque.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA PERSONA';

COMMENT ON COLUMN tramite.solicitudcargaremolque.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA SOLICITUD';

COMMENT ON COLUMN tramite.solicitudcargaremolque.socr_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcargaremolque.socr_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudcargaremolque.socr_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_socr ON
    tramite.solicitudcargaremolque (
        remo_id
    ASC,
        pers_id
    ASC,
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudcargaremolque
    ADD CONSTRAINT pk_socr PRIMARY KEY ( remo_id,
                                         pers_id,
                                         soli_id )
        USING INDEX tramite.pk_socr;

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_CONSIGNACION (
P_CONS_COMPROINGRESO IN CONSIGNACION.CONS_COMPROINGRESO%TYPE,
P_BANC_ID IN CONSIGNACION.BANC_ID%TYPE,
P_MUNI_ID IN CONSIGNACION.MUNI_ID%TYPE,
P_DEPA_ID IN CONSIGNACION.DEPA_ID%TYPE,
P_CONS_VALOR IN CONSIGNACION.CONS_VALOR%TYPE,
P_CONS_FECHA IN CONSIGNACION.CONS_FECHA%TYPE,
P_CONS_NUMERO IN CONSIGNACION.CONS_NUMERO%TYPE,
P_CONS_REGISTRADOPOR IN CONSIGNACION.CONS_REGISTRADOPOR%TYPE,
P_CONS_FECHACAMBIO IN CONSIGNACION.CONS_FECHACAMBIO%TYPE,
P_CONS_PROCESOAUDITORIA IN CONSIGNACION.CONS_PROCESOAUDITORIA%TYPE,
P_SOLI_ID IN CONSIGNACION.SOLI_ID%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.CONSIGNACION(
CONS_COMPROINGRESO,
BANC_ID,
MUNI_ID,
DEPA_ID,
CONS_VALOR,
CONS_FECHA,
CONS_NUMERO,
CONS_REGISTRADOPOR,
CONS_FECHACAMBIO,
CONS_PROCESOAUDITORIA,
SOLI_ID
)
VALUES (
P_CONS_COMPROINGRESO,
P_BANC_ID,
P_MUNI_ID,
P_DEPA_ID,
P_CONS_VALOR,
P_CONS_FECHA,
P_CONS_NUMERO,
P_CONS_REGISTRADOPOR,
P_CONS_FECHACAMBIO,
P_CONS_PROCESOAUDITORIA,
P_SOLI_ID
);

SELECT S_CONS_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE TABLE tramite.solicitudcargaarchivo (
    scar_id                NUMBER(30) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    scar_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    scar_fechacambio       DATE NOT NULL,
    scar_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    scar_tipoarchivo       NUMBER(*, 0) DEFAULT 0
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudcargaarchivo IS
    'Almacena los archivos anexos a las solicitudes de carga extra-dimensionada';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.scar_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.arch_id IS
    'ALMACENA EL IDENTIFICADOR DEL ARCHIVO';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA SOLICITUD';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.scar_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.scar_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcargaarchivo.scar_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.scar_pk ON
    tramite.solicitudcargaarchivo (
        scar_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudcargaarchivo
    ADD CONSTRAINT scar_pk PRIMARY KEY ( scar_id )
        USING INDEX tramite.scar_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_ARCHIVOSESSION (P_SESSION_ID VARCHAR, P_RADICADO VARCHAR) 
as
 
cur_arc_id    NUMBER;
salida  NUMBER;
solicitud_id VARCHAR(20);
BEGIN

select solicitud.SOLI_ID INTO solicitud_id from solicitud where solicitud.SOLI_RADICADO = P_RADICADO; 
 
insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_registradopor,arch_fechacambio,arch_procesoauditoria,arch_descripcion) 
    select  arcs_extension,arcs_nombre,arcs_archivo,'7162',arcs_fechacambio,arcs_procesoauditoria,arcs_session from archivo_session where arcs_session =  P_SESSION_ID;

commit;

insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria) 
     select arch_id,solicitud_id,arch_registradopor,arch_fechacambio,arch_procesoauditoria from archivo where arch_descripcion = P_SESSION_ID;
            
DELETE FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION_ID;
update archivo set arch_descripcion =  '' where arch_descripcion =  P_SESSION_ID;

commit;

  
END;
/

CREATE TABLE tramite.remolque_archivo (
    rear_id                NUMBER(8) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    remo_id                NUMBER(30) NOT NULL,
    rear_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    rear_fechacambio       DATE NOT NULL,
    rear_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    rear_tipo              NUMBER(*, 0) NOT NULL,
    rear_estado            NUMBER(*, 0) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.remolque_archivo_pk ON
    tramite.remolque_archivo (
        rear_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.remolque_archivo
    ADD CONSTRAINT remolque_archivo_pk PRIMARY KEY ( rear_id )
        USING INDEX tramite.remolque_archivo_pk;

CREATE TABLE tramite.vehiculo_archivo (
    vear_id                NUMBER(8) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    vehi_id                NUMBER(30) NOT NULL,
    vear_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    vear_fechacambio       DATE NOT NULL,
    vear_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    vear_tipo              NUMBER(*, 0) NOT NULL,
    vear_estado            NUMBER(*, 0) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.vehiculo_archivo_pk ON
    tramite.vehiculo_archivo (
        vear_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.vehiculo_archivo
    ADD CONSTRAINT vehiculo_archivo_pk PRIMARY KEY ( vear_id )
        USING INDEX tramite.vehiculo_archivo_pk;

CREATE TABLE tramite.persona_archivo (
    pear_id                NUMBER(8) NOT NULL,
    pers_id                NUMBER(8) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    pear_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    pear_fechacambio       DATE NOT NULL,
    pear_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    pear_tipo              NUMBER(*, 0) NOT NULL,
    pear_estado            NUMBER(*, 0) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.persona_archivo_pk ON
    tramite.persona_archivo (
        pear_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.persona_archivo
    ADD CONSTRAINT persona_archivo_pk PRIMARY KEY ( pear_id )
        USING INDEX tramite.persona_archivo_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_SOLICITUD_CARGA (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOCA_FECHAORIGEN      IN SOLICITUDCARGA.SOCA_FECHAORIGEN%TYPE,
P_SOCA_FECHADESTINO     IN SOLICITUDCARGA.SOCA_FECHADESTINO%TYPE,
P_SOCA_DIASMOVILIZACION IN SOLICITUDCARGA.SOCA_DIASMOVILIZACION%TYPE,
P_CONS_VALOR IN CONSIGNACION.CONS_VALOR%TYPE,
P_SOCA_NUMEROEVASION    IN SOLICITUDCARGA.SOCA_NUMEROEVASION%TYPE,
P_VEHI_ID               IN SOLICITUDCARGA.VEHI_ID%TYPE,
P_SOCA_CHARGE                IN SOLICITUDCARGA.CHARGE%TYPE,
P_CAMO_ANCHO                  IN CARGAMOVILIZADA.CAMO_ANCHO%TYPE,
P_CAMO_ALTO                   IN CARGAMOVILIZADA.CAMO_ALTO%TYPE,
P_CAMO_LONGITUDSOBRESALIENTE  IN CARGAMOVILIZADA.CAMO_LONGITUDSOBRESALIENTE%TYPE,
P_CAMO_PESO                   IN CARGAMOVILIZADA.CAMO_PESO%TYPE,
P_REMOLQUES              IN VARCHAR,
P_SESSION              IN VARCHAR,
P_RETORNO OUT VARCHAR,
P_ERROR OUT VARCHAR
)
AS
NUMERO_REGISTROS NUMBER;
NUMRADICADO INT;
VALMAX VARCHAR(100);
PECA VARCHAR(100);
ID_CAMO  NUMBER;
PAPEL_SEG NUMBER;
SOLI_ID NUMBER;
CONS_ID NUMBER;
VALOR_DIA_CARGA NUMBER;
VALOR_PERMISO NUMBER;
l_index INT;
l_comma_index INT;
id_remolque VARCHAR(20);

BEGIN
/*Mayo 10 de 2016, JAFLOREZ
Insertar una solicitud de carga, 
Este procesos inserta una solicitud de carga, esto se hace para atomizar el proceso
y se eviten errores, se han presentando unos errores con unas solicitudes que
se registran y no hay archivos de soporte, el objetivo es poder realizar todo el proceso en 
el servidor de base de datos.

*/

    P_ERROR := '';
    SELECT COUNT(*) INTO NUMERO_REGISTROS FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION;
    DBMS_OUTPUT.PUT_LINE('Llego');
    
    /*Validar si existen registros, se debe garantizar que existan como mínimo dos archivos de soporte*/
/*    IF NUMERO_REGISTROS < 2 THEN
        P_ERROR := 'Numero de archivos errado';
        RAISE VALUE_ERROR; 

    END IF;
    */
    /*Revisar los días de movilización*/
    
    IF P_SOCA_DIASMOVILIZACION < 1 THEN
        P_ERROR := 'El numero de dias, debe ser mayor que cero';
        RAISE VALUE_ERROR; 

    END IF;
    IF P_SOCA_DIASMOVILIZACION > 280 THEN
        P_ERROR := 'Excede el numero maximo de días';
        RAISE VALUE_ERROR; 
    END IF;
    /*Validar el valor del permisio*/
    IF P_CONS_VALOR <= 0 THEN
        P_ERROR := 'El valor del permiso esta errado';
        RAISE VALUE_ERROR; 
    END IF;
    
    /*Calcular el valor del permiso*/
    select TO_NUMBER(PARA_VALORDIACARGA,'99999999') INTO VALOR_DIA_CARGA FROM  PARAMETRIZACION;
    VALOR_PERMISO := VALOR_DIA_CARGA * P_SOCA_DIASMOVILIZACION;
    /*Validar si el valor del permiso esta bien calculado*/
    IF VALOR_PERMISO != P_CONS_VALOR THEN
        DBMS_OUTPUT.PUT_LINE(VALOR_PERMISO);
        P_ERROR := 'El valor del permiso esta errado';
        RAISE VALUE_ERROR; 
    END IF;
    /*Validar la cantida de remolques*/
    
    
    
    /*Determinar el numero de radicado*/
    SELECT MAX ( SUBSTR ( SOLI_RADICADO, 6, 11)) INTO VALMAX FROM SOLICITUD WHERE SOLI_RADICADO LIKE '%PECA_%';
    IF VALMAX IS NULL THEN
        VALMAX := '1';
    END IF; 
    SELECT TO_NUMBER(VALMAX, '999999999') INTO NUMRADICADO FROM DUAL;
    NUMRADICADO := NUMRADICADO+1;
    SELECT 'PECA_' || SUBSTR(TO_CHAR(NUMRADICADO,'00000009999999'),-6,6) INTO PECA FROM DUAL;
    
    /*Inserta la solicitud*/
    PR_TRAMITE_I_SOLICITUD (P_ESSO_ID,1,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_ACTIVARIMPRESION,
     P_SOLI_ACTIVO,P_SOLI_PROCESOAUDITORIA,SYSDATE,P_PERS_ID,PECA,SOLI_ID);
     
    /*Insertar la carga movilizada*/
    
    PR_TRAMITE_I_CARGAMOVILIZADA(P_CAMO_ANCHO,P_CAMO_ALTO,P_CAMO_LONGITUDSOBRESALIENTE,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_PROCESOAUDITORIA,P_CAMO_PESO,ID_CAMO);

    /**/
    SELECT max(soca_seguridad) + 1 INTO PAPEL_SEG  FROM SOLICITUDCARGA where soli_id >205000;
    /*Insertar la solicitud carga*/
    
    PR_TRAMITE_I_SOLICITUDCARGA(SOLI_ID,ID_CAMO,P_SOCA_FECHAORIGEN,P_SOCA_FECHADESTINO,
        P_SOCA_DIASMOVILIZACION,P_SOCA_NUMEROEVASION,'',P_SOLI_REGISTRADOPOR,
        SYSDATE,P_SOLI_PROCESOAUDITORIA,P_PERS_ID,P_VEHI_ID,PAPEL_SEG,'N',P_SOCA_CHARGE);
    /*Insertar remolques*/
     l_index := 1;
    
     LOOP
        l_comma_index := INSTR(P_REMOLQUES, ',', l_index);
        EXIT WHEN l_comma_index = 0;
        id_remolque := SUBSTR(P_REMOLQUES, l_index, l_comma_index - l_index);
        INSERT INTO SOLICITUDCARGAREMOLQUE (REMO_ID, PERS_ID, SOLI_ID, 
            SOCR_REGISTRADOPOR, SOCR_FECHACAMBIO, SOCR_PROCESOAUDITORIA) 
        VALUES(id_remolque,P_PERS_ID,SOLI_ID,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_PROCESOAUDITORIA);
        l_index := l_comma_index + 1;        
     END LOOP;    

    /*Insertar la consignacion*/
    PR_TRAMITE_I_CONSIGNACION('',182,'11001','11',VALOR_PERMISO,SYSDATE,'PARA PAGO',P_SOLI_REGISTRADOPOR,
        SYSDATE,P_SOLI_PROCESOAUDITORIA,SOLI_ID,CONS_ID);
     /*Trasladar los archivos de soporte temporales a la tabla de archivos */
     PR_TRAMITE_I_ARCHIVOSESSION(P_SESSION,PECA);
     
    /*Se cargan los archivos del remolque*/     
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT REMOLQUE_ARCHIVO.ARCH_ID,SOLICITUDCARGAREMOLQUE.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',10 FROM solicitudcargaremolque 
    join remolque_archivo on REMOLQUE_ARCHIVO.REMO_ID = SOLICITUDCARGAREMOLQUE.REMO_ID
    where  REMOLQUE_ARCHIVO.REAR_ESTADO = 1 
    and REMOLQUE_ARCHIVO.REAR_TIPO = 10
    and solicitudcargaremolque.soli_id  = SOLI_ID;

    /*Se cargan los archivos del vehiculo*/
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT vehiculo_archivo.ARCH_ID,SOLICITUDCARGA.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',1 FROM solicitudcarga 
    join vehiculo_archivo on vehiculo_archivo.VEHI_ID = SOLICITUDCARGA.VEHI_ID
    where  vehiculo_archivo.VEAR_ESTADO = 1 
    and vehiculo_archivo.VEAR_TIPO = 1
    and SOLICITUDCARGA.soli_id  = SOLI_ID;
    /*Se cargan los archivos de la persona*/
    
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT persona_archivo.ARCH_ID,SOLICITUDCARGA.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',PERSONA_ARCHIVO.PEAR_TIPO FROM solicitudcarga 
    join persona_archivo on persona_archivo.pers_ID = SOLICITUDCARGA.pers_ID
    where  persona_archivo.peAR_ESTADO = 1 
    and SOLICITUDCARGA.soli_id  = SOLI_ID;

    

     
     
     
     
    /*Insertar un registro del movimiento */
    INSERT INTO MODS(SOLI_ID,MOD_DESCCAMBIO,MOD_NOMCAMBIO,MOD_FECHACAMBIO)
        VALUES(SOLI_ID,'Registro inicial del usuario','INVITRAMITES',sysdate);
    P_RETORNO:= PECA;
    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_SOLICITUD_CARGA_N (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOCA_FECHAORIGEN      IN SOLICITUDCARGA.SOCA_FECHAORIGEN%TYPE,
P_SOCA_FECHADESTINO     IN SOLICITUDCARGA.SOCA_FECHADESTINO%TYPE,
P_SOCA_DIASMOVILIZACION IN SOLICITUDCARGA.SOCA_DIASMOVILIZACION%TYPE,
P_CONS_VALOR IN CONSIGNACION.CONS_VALOR%TYPE,
P_SOCA_NUMEROEVASION    IN SOLICITUDCARGA.SOCA_NUMEROEVASION%TYPE,
P_VEHI_ID               IN SOLICITUDCARGA.VEHI_ID%TYPE,
P_SOCA_CHARGE                IN SOLICITUDCARGA.CHARGE%TYPE,
P_CAMO_ANCHO                  IN CARGAMOVILIZADA.CAMO_ANCHO%TYPE,
P_CAMO_ALTO                   IN CARGAMOVILIZADA.CAMO_ALTO%TYPE,
P_CAMO_LONGITUDSOBRESALIENTE  IN CARGAMOVILIZADA.CAMO_LONGITUDSOBRESALIENTE%TYPE,
P_CAMO_PESO                   IN CARGAMOVILIZADA.CAMO_PESO%TYPE,
P_REMOLQUES              IN VARCHAR,
P_SESSION              IN VARCHAR,
P_RETORNO OUT VARCHAR,
P_ERROR OUT VARCHAR
)
AS
NUMERO_REGISTROS NUMBER;
NUMRADICADO INT;
VALMAX VARCHAR(100);
PECA VARCHAR(100);
ID_CAMO  NUMBER;
PAPEL_SEG NUMBER;
SOLI_ID NUMBER;
CONS_ID NUMBER;
VALOR_DIA_CARGA NUMBER;
VALOR_PERMISO NUMBER;
l_index INT;
l_comma_index INT;
id_remolque VARCHAR(20);

BEGIN
/*Mayo 10 de 2016, JAFLOREZ
Insertar una solicitud de carga, 
Este procesos inserta una solicitud de carga, esto se hace para atomizar el proceso
y se eviten errores, se han presentando unos errores con unas solicitudes que
se registran y no hay archivos de soporte, el objetivo es poder realizar todo el proceso en 
el servidor de base de datos.

*/

    P_ERROR := '';
    SELECT COUNT(*) INTO NUMERO_REGISTROS FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION;
    DBMS_OUTPUT.PUT_LINE('Llego');
    
    /*Validar si existen registros, se debe garantizar que existan como mínimo dos archivos de soporte*/
/*    IF NUMERO_REGISTROS < 2 THEN
        P_ERROR := 'Numero de archivos errado';
        RAISE VALUE_ERROR; 

    END IF;
    */
    /*Revisar los días de movilización*/
    
    IF P_SOCA_DIASMOVILIZACION < 1 THEN
        P_ERROR := 'El numero de dias, debe ser mayor que cero';
        RAISE VALUE_ERROR; 

    END IF;
    IF P_SOCA_DIASMOVILIZACION > 280 THEN
        P_ERROR := 'Excede el numero maximo de días';
        RAISE VALUE_ERROR; 
    END IF;
    /*Validar el valor del permisio*/
    IF P_CONS_VALOR <= 0 THEN
        P_ERROR := 'El valor del permiso esta errado';
        RAISE VALUE_ERROR; 
    END IF;
    
    /*Calcular el valor del permiso*/
    select TO_NUMBER(PARA_VALORDIACARGA,'99999999') INTO VALOR_DIA_CARGA FROM  PARAMETRIZACION;
    VALOR_PERMISO := VALOR_DIA_CARGA * P_SOCA_DIASMOVILIZACION;
    /*Validar si el valor del permiso esta bien calculado*/
    IF VALOR_PERMISO != P_CONS_VALOR THEN
        DBMS_OUTPUT.PUT_LINE(VALOR_PERMISO);
        P_ERROR := 'El valor del permiso esta errado';
        RAISE VALUE_ERROR; 
    END IF;
    /*Validar la cantida de remolques*/
    
    
    
    /*Determinar el numero de radicado*/
    SELECT MAX ( SUBSTR ( SOLI_RADICADO, 6, 11)) INTO VALMAX FROM SOLICITUD WHERE SOLI_RADICADO LIKE '%PECA_%';
    IF VALMAX IS NULL THEN
        VALMAX := '1';
    END IF; 
    SELECT TO_NUMBER(VALMAX, '999999999') INTO NUMRADICADO FROM DUAL;
    NUMRADICADO := NUMRADICADO+1;
    SELECT 'PECA_' || SUBSTR(TO_CHAR(NUMRADICADO,'00000009999999'),-6,6) INTO PECA FROM DUAL;
    
    /*Inserta la solicitud*/
    PR_TRAMITE_I_SOLICITUD (P_ESSO_ID,1,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_ACTIVARIMPRESION,
     P_SOLI_ACTIVO,P_SOLI_PROCESOAUDITORIA,SYSDATE,P_PERS_ID,PECA,SOLI_ID);
     
    /*Insertar la carga movilizada*/
    
    PR_TRAMITE_I_CARGAMOVILIZADA(P_CAMO_ANCHO,P_CAMO_ALTO,P_CAMO_LONGITUDSOBRESALIENTE,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_PROCESOAUDITORIA,P_CAMO_PESO,ID_CAMO);

    /**/
    SELECT max(soca_seguridad) + 1 INTO PAPEL_SEG  FROM SOLICITUDCARGA where soli_id >205000;
    /*Insertar la solicitud carga*/
    
    PR_TRAMITE_I_SOLICITUDCARGA(SOLI_ID,ID_CAMO,P_SOCA_FECHAORIGEN,P_SOCA_FECHADESTINO,
        P_SOCA_DIASMOVILIZACION,P_SOCA_NUMEROEVASION,'',P_SOLI_REGISTRADOPOR,
        SYSDATE,P_SOLI_PROCESOAUDITORIA,P_PERS_ID,P_VEHI_ID,PAPEL_SEG,'N',P_SOCA_CHARGE);
    /*Insertar remolques*/
     l_index := 1;
    
     LOOP
        l_comma_index := INSTR(P_REMOLQUES, ',', l_index);
        EXIT WHEN l_comma_index = 0;
        id_remolque := SUBSTR(P_REMOLQUES, l_index, l_comma_index - l_index);
        INSERT INTO SOLICITUDCARGAREMOLQUE (REMO_ID, PERS_ID, SOLI_ID, 
            SOCR_REGISTRADOPOR, SOCR_FECHACAMBIO, SOCR_PROCESOAUDITORIA) 
        VALUES(id_remolque,P_PERS_ID,SOLI_ID,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_PROCESOAUDITORIA);
        l_index := l_comma_index + 1;        
     END LOOP;    

    /*Insertar la consignacion*/
    PR_TRAMITE_I_CONSIGNACION('',182,'11001','11',VALOR_PERMISO,SYSDATE,'PARA PAGO',P_SOLI_REGISTRADOPOR,
        SYSDATE,P_SOLI_PROCESOAUDITORIA,SOLI_ID,CONS_ID);
     /*Trasladar los archivos de soporte temporales a la tabla de archivos */
     PR_TRAMITE_I_ARCHIVOSESSION(P_SESSION,PECA);
     
    /*Se cargan los archivos del remolque*/     
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT REMOLQUE_ARCHIVO.ARCH_ID,SOLICITUDCARGAREMOLQUE.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',10 FROM solicitudcargaremolque 
    join remolque_archivo on REMOLQUE_ARCHIVO.REMO_ID = SOLICITUDCARGAREMOLQUE.REMO_ID
    where  REMOLQUE_ARCHIVO.REAR_ESTADO = 1 
    and REMOLQUE_ARCHIVO.REAR_TIPO = 10
    and solicitudcargaremolque.soli_id  = SOLI_ID;

    /*Se cargan los archivos del vehiculo*/
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT vehiculo_archivo.ARCH_ID,SOLICITUDCARGA.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',1 FROM solicitudcarga 
    join vehiculo_archivo on vehiculo_archivo.VEHI_ID = SOLICITUDCARGA.VEHI_ID
    where  vehiculo_archivo.VEAR_ESTADO = 1 
    and vehiculo_archivo.VEAR_TIPO = 1
    and SOLICITUDCARGA.soli_id  = SOLI_ID;
    /*Se cargan los archivos de la persona*/
    
    insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria,scar_tipoarchivo)
    SELECT persona_archivo.ARCH_ID,SOLICITUDCARGA.SOLI_ID, 7323,sysdate,'Solicitud de Tramites en Linea (INVIAS).agregar Archivo Carga',PERSONA_ARCHIVO.PEAR_TIPO FROM solicitudcarga 
    join persona_archivo on persona_archivo.pers_ID = SOLICITUDCARGA.pers_ID
    where  persona_archivo.peAR_ESTADO = 1 
    and SOLICITUDCARGA.soli_id  = SOLI_ID;

    

     
     
     
     
    /*Insertar un registro del movimiento */
    INSERT INTO MODS(SOLI_ID,MOD_DESCCAMBIO,MOD_NOMCAMBIO,MOD_FECHACAMBIO)
        VALUES(SOLI_ID,'Registro inicial del usuario','INVITRAMITES',sysdate);
    P_RETORNO:= PECA;
    
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso de valor';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.solicitudpermisoespecial (
    soli_id                     NUMBER(30) NOT NULL,
    sope_fechaoficio            DATE,
    sope_fechacaducidad         DATE,
    sope_valor                  VARCHAR2(50 BYTE),
    sope_fecharegistro          DATE DEFAULT sysdate,
    sope_resolucion             VARCHAR2(20 BYTE),
    sope_fecharesolucion        DATE,
    sope_vigencia               DATE,
    sope_placa                  VARCHAR2(20 BYTE),
    sope_fechanotificacion      DATE,
    sope_vehiculo_propio        NUMBER(*, 0),
    sope_tipo_permiso           NUMBER(*, 0),
    sope_numero_dias            NUMBER(*, 0),
    sope_fecha_desde            DATE,
    sope_fecha_hasta            DATE,
    sope_repre_legal_cedula     VARCHAR2(12 BYTE),
    sope_repre_legal_nombre     VARCHAR2(200 BYTE),
    sope_autoriza_notificacion  NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecial_pk ON
    tramite.solicitudpermisoespecial (
        soli_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecial
    ADD CONSTRAINT solicitudpermisoespecial_pk PRIMARY KEY ( soli_id )
        USING INDEX tramite.solicitudpermisoespecial_pk;

CREATE TABLE tramite.estadosolicitud (
    esso_id                 NUMBER(30) NOT NULL,
    esso_descripcion        VARCHAR2(200 BYTE) NOT NULL,
    esso_tipoestado         VARCHAR2(30 BYTE) NOT NULL,
    esso_registradopor      VARCHAR2(30 BYTE) NOT NULL,
    esso_fechacambio        DATE NOT NULL,
    esso_procesoauditoria   VARCHAR2(300 BYTE) NOT NULL,
    esso_texto_alternativo  VARCHAR2(20 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.estadosolicitud IS
    'Almacena los estados por los que pasa una solicitud de tramite';

COMMENT ON COLUMN tramite.estadosolicitud.esso_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.estadosolicitud.esso_descripcion IS
    'ALMACENA LA DESCRIPCION DEL ESTADO DE LA SOLICITUD';

COMMENT ON COLUMN tramite.estadosolicitud.esso_tipoestado IS
    'ALMACENA EL TIPO ESTADO DE LA SOLICITUD. I=INICIAL, M=MEDIO, F=FINAL';

COMMENT ON COLUMN tramite.estadosolicitud.esso_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.estadosolicitud.esso_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.estadosolicitud.esso_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_esso_esso_descrip ON
    tramite.estadosolicitud (
        esso_descripcion
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_esso ON
    tramite.estadosolicitud (
        esso_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.estadosolicitud TO tramite_consulta;

ALTER TABLE tramite.estadosolicitud
    ADD CONSTRAINT pk_esso PRIMARY KEY ( esso_id )
        USING INDEX tramite.pk_esso;

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_SOLICITUD_ASIG (
P_ESSO_ID IN SOLICITUD.ESSO_ID%TYPE,
P_SOLI_ASIGNADO IN SOLICITUD.SOLI_ASIGNADO%TYPE,
P_TRAM_ID IN SOLICITUD.TRAM_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_FECHACAMBIO IN SOLICITUD.SOLI_FECHACAMBIO%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_SOLI_FECHA IN SOLICITUD.SOLI_FECHA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOLI_RADICADO IN SOLICITUD.SOLI_RADICADO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLICITUD(
ESSO_ID,
SOLI_ASIGNADO,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_RADICADO
)
VALUES (
P_ESSO_ID,
P_SOLI_ASIGNADO,
P_TRAM_ID,
P_SOLI_REGISTRADOPOR,
P_SOLI_FECHACAMBIO,
P_SOLI_ACTIVARIMPRESION,
P_SOLI_ACTIVO,
P_SOLI_PROCESOAUDITORIA,
P_SOLI_FECHA,
P_PERS_ID,
P_SOLI_RADICADO
);

SELECT S_SOLI_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_SOLICITUDESPECIAL(
  P_SOLI_ID                 IN SOLICITUDPERMISOESPECIAL.SOLI_ID%TYPE,
  P_SOPE_FECHAOFICIO        IN SOLICITUDPERMISOESPECIAL.SOPE_FECHAOFICIO%TYPE,
  P_SOPE_FECHACADUCIDAD     IN SOLICITUDPERMISOESPECIAL.SOPE_FECHACADUCIDAD%TYPE,
  P_SOPE_VALOR              IN SOLICITUDPERMISOESPECIAL.SOPE_VALOR%TYPE,
  P_SOPE_RESOLUCION         IN SOLICITUDPERMISOESPECIAL.SOPE_RESOLUCION%TYPE,
  P_SOPE_FECHARESOLUCION    IN SOLICITUDPERMISOESPECIAL.SOPE_FECHARESOLUCION%TYPE,
  P_SOPE_VIGENCIA           IN SOLICITUDPERMISOESPECIAL.SOPE_VIGENCIA%TYPE,
  P_SOPE_PLACA              IN SOLICITUDPERMISOESPECIAL.SOPE_PLACA%TYPE,
  P_SOPE_FECHANOTIFICACION  IN SOLICITUDPERMISOESPECIAL.SOPE_FECHANOTIFICACION%TYPE,
  P_SOPE_VEHICULO_PROPIO    IN SOLICITUDPERMISOESPECIAL.SOPE_VEHICULO_PROPIO%TYPE,
  P_SOPE_TIPO_PERMISO       IN SOLICITUDPERMISOESPECIAL.SOPE_TIPO_PERMISO%TYPE,
  P_SOPE_NUMERO_DIAS        IN SOLICITUDPERMISOESPECIAL.SOPE_NUMERO_DIAS%TYPE,
  P_SOPE_FECHA_DESDE        IN SOLICITUDPERMISOESPECIAL.SOPE_FECHA_DESDE %TYPE,
  P_SOPE_FECHA_HASTA        IN SOLICITUDPERMISOESPECIAL.SOPE_FECHA_HASTA%TYPE,
  P_SOPE_REPRE_LEGAL_CEDULA IN SOLICITUDPERMISOESPECIAL.SOPE_REPRE_LEGAL_CEDULA%TYPE,
  P_SOPE_REPRE_LEGAL_NOMBRE IN SOLICITUDPERMISOESPECIAL.SOPE_REPRE_LEGAL_NOMBRE%TYPE
)
AS
E_ERROR EXCEPTION;
BEGIN
INSERT INTO tramite.SOLICITUDPERMISOESPECIAL(
SOLI_ID,
SOPE_FECHAOFICIO,
SOPE_FECHACADUCIDAD,
SOPE_VALOR,
SOPE_RESOLUCION,
SOPE_FECHARESOLUCION,
SOPE_VIGENCIA,
SOPE_PLACA,
SOPE_FECHANOTIFICACION,
SOPE_VEHICULO_PROPIO,
SOPE_TIPO_PERMISO,
SOPE_NUMERO_DIAS,
SOPE_FECHA_DESDE,
SOPE_FECHA_HASTA,
SOPE_REPRE_LEGAL_CEDULA,
SOPE_REPRE_LEGAL_NOMBRE
)
VALUES (
P_SOLI_ID,
P_SOPE_FECHAOFICIO,
P_SOPE_FECHACADUCIDAD,
P_SOPE_VALOR,
P_SOPE_RESOLUCION,
P_SOPE_FECHARESOLUCION,
P_SOPE_VIGENCIA,
P_SOPE_PLACA,
P_SOPE_FECHANOTIFICACION,
P_SOPE_VEHICULO_PROPIO,
P_SOPE_TIPO_PERMISO,
P_SOPE_NUMERO_DIAS,
P_SOPE_FECHA_DESDE,
P_SOPE_FECHA_HASTA,
P_SOPE_REPRE_LEGAL_CEDULA,
P_SOPE_REPRE_LEGAL_NOMBRE
);

END;
/

CREATE TABLE tramite.solicitudpermisoespecialarch (
    arch_id                 NUMBER(30) NOT NULL,
    soli_id                 NUMBER(30) NOT NULL,
    sope_registradopor      VARCHAR2(30 BYTE) NOT NULL,
    sope_fechacambio        DATE NOT NULL,
    sope_procesoauditoria   VARCHAR2(300 BYTE) NOT NULL,
    sope_id                 NUMBER(8) NOT NULL,
    arch_publico            NUMBER(1) DEFAULT 0,
    arch_tipo               NUMBER(*, 0),
    arch_estado             NUMBER(*, 0),
    pers_id_ani             NUMBER(8),
    arc_observacion_ani     VARCHAR2(1500 BYTE),
    arc_fecha_ani           DATE,
    pers_id_invias          NUMBER(8),
    arc_observacion_invias  VARCHAR2(1500 BYTE),
    arc_fecha_invias        DATE,
    arcs_fechasoat          DATE
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialar_u01 ON
    tramite.solicitudpermisoespecialarch (
        sope_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.uk_solperesparch ON
    tramite.solicitudpermisoespecialarch (
        arch_id
    ASC,
        soli_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialarch
    ADD CONSTRAINT solicitudpermisoespecialarchpk PRIMARY KEY ( sope_id )
        USING INDEX tramite.solicitudpermisoespecialar_u01;

ALTER TABLE tramite.solicitudpermisoespecialarch
    ADD CONSTRAINT uk_solperesparch UNIQUE ( arch_id,
                                             soli_id )
        USING INDEX tramite.uk_solperesparch;

CREATE TABLE tramite.solicitudpermisoespecialvehi (
    vehi_id                NUMBER(30) NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    vear_id_licencia       NUMBER(10) NOT NULL,
    vear_id_catalogo       NUMBER(10) NOT NULL,
    seve_fechacambio       DATE NOT NULL,
    seve_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    seve_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    seve_id                NUMBER(15) NOT NULL,
    vear_id_soat           NUMBER(10),
    vear_id_vinculo        NUMBER(10),
    seve_fechasoat         DATE
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialvehipk ON
    tramite.solicitudpermisoespecialvehi (
        seve_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialvehipk PRIMARY KEY ( seve_id )
        USING INDEX tramite.solicitudpermisoespecialvehipk;

CREATE TABLE tramite.solicitudpermisoespecialremo (
    remo_id                NUMBER(30) NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    rear_id_licencia       NUMBER(30) NOT NULL,
    sere_fechacambio       DATE NOT NULL,
    sere_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    sere_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    sere_id                NUMBER(30) NOT NULL,
    rear_id_catalogo       NUMBER(30)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialremopk ON
    tramite.solicitudpermisoespecialremo (
        sere_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialremo
    ADD CONSTRAINT solicitudpermisoespecialremopk PRIMARY KEY ( sere_id )
        USING INDEX tramite.solicitudpermisoespecialremopk;

CREATE TABLE tramite.solicitudpermisoespecialruta (
    seru_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    seru_codvia            VARCHAR2(20 BYTE),
    seru_nombre            VARCHAR2(400 BYTE),
    seru_pr_inicial        VARCHAR2(20 BYTE),
    seru_pr_final          VARCHAR2(20 BYTE),
    seru_tramo             VARCHAR2(200 BYTE),
    seru_sector            VARCHAR2(200 BYTE),
    seru_entidad           VARCHAR2(50 BYTE),
    seru_territorial       VARCHAR2(100 BYTE),
    seru_ancho             NUMBER(5, 2),
    seru_altura            NUMBER(5, 2),
    seru_peso              NUMBER(5, 2),
    seru_longitud          NUMBER(5, 2),
    seru_parcial           NUMBER(*, 0),
    seru_descripcion       VARCHAR2(600 BYTE),
    seru_fechacambio       DATE NOT NULL,
    seru_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    seru_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    seru_aprobado          VARCHAR2(20 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialrutapk ON
    tramite.solicitudpermisoespecialruta (
        seru_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialruta
    ADD CONSTRAINT solicitudpermisoespecialrutapk PRIMARY KEY ( seru_id )
        USING INDEX tramite.solicitudpermisoespecialrutapk;

CREATE TABLE tramite.solicitudpermisoespecialrtases (
    sert_id           NUMBER(30) NOT NULL,
    sert_codvia       VARCHAR2(20 BYTE),
    sert_nombre       VARCHAR2(400 BYTE),
    sert_pr_inicial   VARCHAR2(20 BYTE),
    sert_pr_final     VARCHAR2(20 BYTE),
    sert_tramo        VARCHAR2(200 BYTE),
    sert_sector       VARCHAR2(200 BYTE),
    sert_entidad      VARCHAR2(50 BYTE),
    sert_territorial  VARCHAR2(100 BYTE),
    sert_ancho        NUMBER(5, 2),
    sert_altura       NUMBER(5, 2),
    sert_peso         NUMBER(5, 2),
    sert_longitud     NUMBER(5, 2),
    sert_parcial      NUMBER(*, 0),
    sert_descripcion  VARCHAR2(600 BYTE),
    sert_session      VARCHAR2(400 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_INSERTAR_SOLICITUD_ESPECIAL (
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_ACTIVARIMPRESION IN SOLICITUD.SOLI_ACTIVARIMPRESION%TYPE,
P_SOLI_ACTIVO IN SOLICITUD.SOLI_ACTIVO%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_PERS_ID IN SOLICITUD.PERS_ID%TYPE,
P_SOPE_PLACA IN SOLICITUDPERMISOESPECIAL.SOPE_PLACA%TYPE,
P_SOPE_VEHICULO_PROPIO IN SOLICITUDPERMISOESPECIAL.SOPE_VEHICULO_PROPIO%TYPE,
P_SOPE_TIPO_PERMISO IN SOLICITUDPERMISOESPECIAL.SOPE_TIPO_PERMISO%TYPE,
P_SOPE_NUMERO_DIAS IN SOLICITUDPERMISOESPECIAL.SOPE_NUMERO_DIAS%TYPE,
P_SOPE_REPRE_LEGAL_CEDULA IN SOLICITUDPERMISOESPECIAL.SOPE_REPRE_LEGAL_CEDULA%TYPE,
P_SOPE_REPRE_LEGAL_NOMBRE IN SOLICITUDPERMISOESPECIAL.SOPE_REPRE_LEGAL_NOMBRE%TYPE,
P_REMOLQUES              IN VARCHAR,
P_SESSION               IN VARCHAR,
P_ERROR OUT VARCHAR,
R_SOLI_ID OUT VARCHAR,
R_SOLI_RADICADO OUT VARCHAR
)
AS
CUR_SOLI_ID NUMBER;
CUR_CONS_ID NUMBER;
NUMRADICADO INT;
VALMAX VARCHAR(100);
PEES VARCHAR(100);
ASIGNADO VARCHAR(100);
NUMERO_REGISTROS INT;
P_ESSO_ID SOLICITUD.ESSO_ID%TYPE;
BEGIN
    SELECT COUNT(*) INTO NUMERO_REGISTROS FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION;
    /*Validar si existen registros, se debe garantizar que existan como mínimo dos archivos de soporte*/
    IF NUMERO_REGISTROS < 0 THEN
        P_ERROR := 'Numero de archivos errado';
        RAISE VALUE_ERROR; 
    END IF;
    SELECT MAX ( SUBSTR (SOLI_RADICADO, 6, 11)) INTO VALMAX FROM SOLICITUD WHERE SOLI_RADICADO LIKE '%PEES_%';
    IF VALMAX IS NULL THEN
        VALMAX := '1';
    END IF; 
    SELECT TO_NUMBER(VALMAX, '999999999') INTO NUMRADICADO FROM DUAL;
    NUMRADICADO := NUMRADICADO+1;
    SELECT 'PEES_' || SUBSTR(TO_CHAR(NUMRADICADO,'00000009999999'),-6,6) INTO PEES FROM DUAL;
    /*Inserta la solicitud*/
    /*Se determina el estado inicial*/
    SELECT  tramiteestadosolicitud.esso_id  
        INTO P_ESSO_ID 
    FROM tramiteestadosolicitud 
        JOIN ESTADOSOLICITUD on ESTADOSOLICITUD.ESSO_ID = TRAMITEESTADOSOLICITUD.ESSO_ID
    WHERE 
        tram_id = 41 and esso_tipoestado = 'I';

    SELECT  pers_id into  ASIGNADO FROM tramiteEstadoSolicitud WHERE tram_id = 41 AND esso_id = P_ESSO_ID;


    PR_TRAMITE_I_SOLICITUD_ASIG (P_ESSO_ID,ASIGNADO,41,P_SOLI_REGISTRADOPOR,SYSDATE,P_SOLI_ACTIVARIMPRESION,
     P_SOLI_ACTIVO,P_SOLI_PROCESOAUDITORIA,SYSDATE,P_PERS_ID,PEES,CUR_SOLI_ID);
     /*Insertar el registro del movimiento*/
     INSERT INTO MODS(SOLI_ID,MOD_DESCCAMBIO,MOD_NOMCAMBIO,MOD_FECHACAMBIO)   VALUES(CUR_SOLI_ID,'Registro inicial del usuario','INVITRAMITES',sysdate);     
    /*Insertar la carga solicitud especial*/
    PR_TRAMITE_I_SOLICITUDESPECIAL ( CUR_SOLI_ID, null, null, null, null,null, null, P_SOPE_PLACA, null, P_SOPE_VEHICULO_PROPIO, P_SOPE_TIPO_PERMISO, P_SOPE_NUMERO_DIAS, null, null,P_SOPE_REPRE_LEGAL_CEDULA,P_SOPE_REPRE_LEGAL_NOMBRE);
    /*Actualizar el estado de la solicitud */



    /*Insertar los archivos de vehiculos (17) son los archivos del SOAT*/
    INSERT INTO ARCHIVO(ARCH_EXTENSION,ARCH_NOMBRE,ARCH_ARCHIVO,ARCH_REGISTRADOPOR,ARCH_FECHACAMBIO,ARCH_PROCESOAUDITORIA,ARCH_DESCRIPCION)
    SELECT              ARCS_EXTENSION,ARCS_NOMBRE,ARCS_ARCHIVO,ARCS_PROCESOAUDITORIA,ARCS_FECHASOAT,ARCS_DESCRIPCION,ARCS_SESSION
    from  archivo_session where arcs_session = P_SESSION
    and arcs_descripcion = '17';

    /*Insertar en la tabla de archivos de la solicitud especial*/

    INSERT INTO SOLICITUDPERMISOESPECIALARCH(ARCH_ID,SOLI_ID,SOPE_REGISTRADOPOR,ARCS_FECHASOAT,SOPE_FECHACAMBIO,SOPE_PROCESOAUDITORIA,ARCH_TIPO,ARCH_ESTADO)
    SELECT arch_id,CUR_SOLI_ID,arch_nombre,arch_fechacambio,sysdate,arch_registradopor,17 AS arc_tipo,1 as arc_estado FROM archivo
    where ARCH_DESCRIPCION = P_SESSION and arch_procesoauditoria = '17';
    /*Insertar en solicitud_especial_vehiculo*/

    INSERT 
        INTO SOLICITUDPERMISOESPECIALVEHI(VEHI_ID,PERS_ID, SOLI_ID,VEAR_ID_LICENCIA,VEAR_ID_CATALOGO,
        SEVE_FECHACAMBIO,VEAR_ID_SOAT,SEVE_PROCESOAUDITORIA,SEVE_REGISTRADOPOR,SEVE_FECHASOAT)
    SELECT 
        TO_NUMBER(trim(SAR.SOPE_PROCESOAUDITORIA)),P_PERS_ID,CUR_SOLI_ID,val.vear_id as id_licencia,VAC.vear_id as id_catalogo,
        sysdate,SAR.SOPE_ID,P_SOLI_PROCESOAUDITORIA,7162,SAR.ARCS_FECHASOAT 
    FROM SOLICITUDPERMISOESPECIALARCH SAR,vehiculo_archivo VAL,vehiculo_archivo VAC 
        WHERE     VAL.VEHI_ID = SAR.SOPE_PROCESOAUDITORIA and VAL.VEAR_ESTADO = 1 and VAL.VEAR_TIPO = 1 
        AND VAC.VEHI_ID = SAR.SOPE_PROCESOAUDITORIA AND VAC.VEAR_ESTADO = 1 AND  VAC.VEAR_TIPO = 2
        AND SAR.soli_id = CUR_SOLI_ID and SAR.arch_tipo = 17 and SAR.arch_estado = 1;

    /*Insertar los demas archivos en la tabla de archivos */

    insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_fechacambio,arch_procesoauditoria,arch_descripcion,arch_registradopor)
    select arcs_extension,arcs_nombre,arcs_archivo,sysdate,arcs_descripcion,arcs_session,7162   from archivo_session where arcs_session = P_SESSION and arcs_descripcion != 17;

    insert into SOLICITUDPERMISOESPECIALARCH(arch_id,soli_id,sope_registradopor,sope_fechacambio,sope_procesoauditoria,arch_tipo,arch_estado)
    select arch_id,CUR_SOLI_ID,7162,sysdate,P_SOLI_PROCESOAUDITORIA,arch_procesoauditoria,1 from archivo where arch_descripcion = P_SESSION and arch_procesoauditoria != '17';
    /*Insertar remolques*/
    INSERT INTO solicitudpermisoespecialremo(remo_id,pers_id,soli_id,rear_id_catalogo,rear_id_licencia,sere_fechacambio,sere_registradopor,sere_procesoauditoria)
         SELECT RA.REMO_ID,P_PERS_ID,CUR_SOLI_ID,RA.rear_id as id_catalodo,RA2.rear_id as id_licencia ,
            sysdate,7182,P_SOLI_PROCESOAUDITORIA 
         FROM  remolque_archivo RA
             LEFT JOIN remolque_archivo RA2 ON RA.REMO_ID = RA2.REMO_ID AND RA2.REAR_TIPO = 10 AND RA2.REAR_ESTADO=1
         WHERE  INSTR(P_REMOLQUES,to_char(RA.REMO_ID))>0  
             AND RA.rear_estado = 1 
             AND RA.rear_tipo = 7;
    
    
    /*Insertar rutas*/
    insert into SOLICITUDPERMISOESPECIALRUTA(soli_id,SERU_CODVIA,SERU_PR_INICIAL,SERU_PR_FINAL,SERU_TRAMO,SERU_SECTOR,SERU_ENTIDAD,SERU_TERRITORIAL,seru_registradopor,seru_ancho,seru_altura,seru_peso,seru_longitud,seru_parcial,seru_descripcion,seru_fechacambio,seru_procesoauditoria)
    select CUR_SOLI_ID,SERT_CODVIA,SERT_PR_INICIAL,SERT_PR_FINAL,SERT_TRAMO,SERT_SECTOR,SERT_ENTIDAD,SERT_TERRITORIAL,7182,sert_ancho,sert_altura,sert_peso,sert_longitud,sert_parcial,sert_descripcion,sysdate,'Registro inicial del usuario' from SOLICITUDPERMISOESPECIALRTASES  where sert_session = P_SESSION;
     /*Insertar consignacion*/
     PR_TRAMITE_I_CONSIGNACION('',182,'11001','11',0,SYSDATE,'Por Definir','7182',SYSDATE,P_SOLI_PROCESOAUDITORIA,CUR_SOLI_ID,CUR_CONS_ID);
    /*Arreglar los nombres de archivo*/
    update archivo set arch_descripcion = 'Archivo de Soporte',arch_procesoauditoria=P_SOLI_PROCESOAUDITORIA where arch_descripcion = P_SESSION;
    /*Eliminar los archivos de session*/
   -- DELETE FROM ARCHIVO_SESSION WHERE ARCS_SESSION = P_SESSION;
   -- DELETE FROM SOLICITUDPERMISOESPECIALRTASES WHERE sert_session = P_SESSION;
    R_SOLI_ID := CUR_SOLI_ID;
    R_SOLI_RADICADO := PEES;
    COMMIT;
exception
    WHEN VALUE_ERROR
        THEN 
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
    WHEN OTHERS
           THEN
            IF P_ERROR = '' THEN
                P_ERROR := 'Error en el proceso';
            END IF;
                RAISE;
END;
/

CREATE TABLE tramite.aud_archivo (
    arch_id                NUMBER(30),
    arch_extension         VARCHAR2(10 BYTE),
    arch_nombre            VARCHAR2(100 BYTE),
    arch_archivo           BLOB,
    arch_registradopor     VARCHAR2(30 BYTE),
    arch_fechacambio       DATE,
    arch_procesoauditoria  VARCHAR2(300 BYTE),
    arch_descripcion       VARCHAR2(500 BYTE),
    arch_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 196608 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
    LOB ( arch_archivo ) STORE AS (
        TABLESPACE tramitedat
        STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
        CHUNK 8192
        RETENTION
        ENABLE STORAGE IN ROW
        NOCACHE LOGGING
    );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_ARCHIVO (
P_ARCH_ID IN ARCHIVO.ARCH_ID%TYPE,
P_ARCH_REGISTRADOPOR IN ARCHIVO.ARCH_REGISTRADOPOR%TYPE,
P_ARCH_PROCESOAUDITORIA IN ARCHIVO.ARCH_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_ARCHIVO(
ARCH_ID,
ARCH_EXTENSION,
ARCH_NOMBRE,
ARCH_ARCHIVO,
ARCH_REGISTRADOPOR,
ARCH_FECHACAMBIO,
ARCH_PROCESOAUDITORIA,
ARCH_DESCRIPCION,
ARCH_OPERACION
)
SELECT
ARCH_ID,
ARCH_EXTENSION,
ARCH_NOMBRE,
ARCH_ARCHIVO,
P_ARCH_REGISTRADOPOR,
SYSDATE,
P_ARCH_PROCESOAUDITORIA,
ARCH_DESCRIPCION,
'D'
FROM TRAMITE.ARCHIVO WHERE ARCH_ID = P_ARCH_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.ARCHIVO WHERE ARCH_ID = P_ARCH_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.banco (
    banc_id                NUMBER(30) NOT NULL,
    banc_nombre            VARCHAR2(100 BYTE) NOT NULL,
    banc_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    banc_fechacambio       DATE NOT NULL,
    banc_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.banco IS
    'Almacena los bancos donde se puede realizar la consignacion de los tramites de carga extra-dimensionada';

COMMENT ON COLUMN tramite.banco.banc_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.banco.banc_nombre IS
    'ALMACENA EL NOMBRE DEL BANCO';

COMMENT ON COLUMN tramite.banco.banc_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.banco.banc_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.banco.banc_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_banc_banc_nombre ON
    tramite.banco (
        banc_nombre
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_banc ON
    tramite.banco (
        banc_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.banco
    ADD CONSTRAINT pk_banc PRIMARY KEY ( banc_id )
        USING INDEX tramite.pk_banc;

CREATE TABLE tramite.aud_banco (
    banc_id                NUMBER(30),
    banc_nombre            VARCHAR2(100 BYTE),
    banc_registradopor     VARCHAR2(30 BYTE),
    banc_fechacambio       DATE,
    banc_procesoauditoria  VARCHAR2(300 BYTE),
    banc_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_BANCO (
P_BANC_ID IN BANCO.BANC_ID%TYPE,
P_BANC_REGISTRADOPOR IN BANCO.BANC_REGISTRADOPOR%TYPE,
P_BANC_PROCESOAUDITORIA IN BANCO.BANC_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_BANCO(
BANC_ID,
BANC_NOMBRE,
BANC_REGISTRADOPOR,
BANC_FECHACAMBIO,
BANC_PROCESOAUDITORIA,
BANC_OPERACION
)
SELECT
BANC_ID,
BANC_NOMBRE,
P_BANC_REGISTRADOPOR,
SYSDATE,
P_BANC_PROCESOAUDITORIA,
'D'
FROM TRAMITE.BANCO WHERE BANC_ID = P_BANC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.BANCO WHERE BANC_ID = P_BANC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_cargamovilizada (
    camo_id                     NUMBER(30),
    camo_ancho                  VARCHAR2(100 BYTE),
    camo_alto                   VARCHAR2(100 BYTE),
    camo_longitudsobresaliente  VARCHAR2(100 BYTE),
    camo_registradopor          VARCHAR2(30 BYTE),
    camo_fechacambio            DATE,
    camo_procesoauditoria       VARCHAR2(300 BYTE),
    camo_operacion              VARCHAR2(1 BYTE) NOT NULL,
    camo_peso                   VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_CARGAMOVILIZADA (
P_CAMO_ID IN CARGAMOVILIZADA.CAMO_ID%TYPE,
P_CAMO_REGISTRADOPOR IN CARGAMOVILIZADA.CAMO_REGISTRADOPOR%TYPE,
P_CAMO_PROCESOAUDITORIA IN CARGAMOVILIZADA.CAMO_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_CARGAMOVILIZADA(
CAMO_ID,
CAMO_ANCHO,
CAMO_ALTO,
CAMO_LONGITUDSOBRESALIENTE,
CAMO_REGISTRADOPOR,
CAMO_FECHACAMBIO,
CAMO_PROCESOAUDITORIA,
CAMO_OPERACION,
CAMO_PESO
)
SELECT
CAMO_ID,
CAMO_ANCHO,
CAMO_ALTO,
CAMO_LONGITUDSOBRESALIENTE,
P_CAMO_REGISTRADOPOR,
SYSDATE,
P_CAMO_PROCESOAUDITORIA,
'D',
CAMO_PESO
FROM TRAMITE.CARGAMOVILIZADA WHERE CAMO_ID = P_CAMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.CARGAMOVILIZADA WHERE CAMO_ID = P_CAMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.cargamovilizadatipocarga (
    tica_id                NUMBER(30) NOT NULL,
    camo_id                NUMBER(30) NOT NULL,
    cmtc_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    cmtc_fechacambio       DATE NOT NULL,
    cmtc_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.cargamovilizadatipocarga IS
    'Almacena los tipos de carga que se indican en la solicitud de carga extra-dimensionada';

COMMENT ON COLUMN tramite.cargamovilizadatipocarga.tica_id IS
    'ALMACENA EL IDENTIFICADOR DEL TIPO CARGA';

COMMENT ON COLUMN tramite.cargamovilizadatipocarga.camo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA CARGA MOVILIZADA';

COMMENT ON COLUMN tramite.cargamovilizadatipocarga.cmtc_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.cargamovilizadatipocarga.cmtc_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.cargamovilizadatipocarga.cmtc_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.cmtp_pk ON
    tramite.cargamovilizadatipocarga (
        tica_id
    ASC,
        camo_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.cargamovilizadatipocarga
    ADD CONSTRAINT cmtp_pk PRIMARY KEY ( tica_id,
                                         camo_id )
        USING INDEX tramite.cmtp_pk;

CREATE TABLE tramite.aud_cargamovilizadatipocarga (
    tica_id                NUMBER(30),
    camo_id                NUMBER(30),
    cmtc_registradopor     VARCHAR2(30 BYTE),
    cmtc_fechacambio       DATE,
    cmtc_procesoauditoria  VARCHAR2(300 BYTE),
    cmtc_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_CARMOVITIPOCARGA (
P_TICA_ID IN CARGAMOVILIZADATIPOCARGA.TICA_ID%TYPE,
P_CAMO_ID IN CARGAMOVILIZADATIPOCARGA.CAMO_ID%TYPE,
P_CMTC_REGISTRADOPOR IN CARGAMOVILIZADATIPOCARGA.CMTC_REGISTRADOPOR%TYPE,
P_CMTC_PROCESOAUDITORIA IN CARGAMOVILIZADATIPOCARGA.CMTC_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_CARGAMOVILIZADATIPOCARGA(
TICA_ID,
CAMO_ID,
CMTC_REGISTRADOPOR,
CMTC_FECHACAMBIO,
CMTC_PROCESOAUDITORIA,
CMTC_OPERACION
)
SELECT
TICA_ID,
CAMO_ID,
P_CMTC_REGISTRADOPOR,
SYSDATE,
P_CMTC_PROCESOAUDITORIA,
'D'
FROM TRAMITE.CARGAMOVILIZADATIPOCARGA WHERE TICA_ID = P_TICA_ID AND
CAMO_ID = P_CAMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.CARGAMOVILIZADATIPOCARGA WHERE TICA_ID = P_TICA_ID AND
CAMO_ID = P_CAMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_consignacion (
    cons_id                NUMBER(30),
    banc_id                NUMBER(30),
    muni_id                VARCHAR2(30 BYTE),
    depa_id                VARCHAR2(30 BYTE),
    cons_valor             VARCHAR2(50 BYTE),
    cons_fecha             DATE,
    cons_numero            VARCHAR2(50 BYTE),
    cons_registradopor     VARCHAR2(30 BYTE),
    cons_fechacambio       DATE,
    cons_procesoauditoria  VARCHAR2(300 BYTE),
    soli_id                NUMBER(30),
    cons_operacion         VARCHAR2(1 BYTE) NOT NULL,
    cons_comproingreso     VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_CONSIGNACION (
P_CONS_ID IN CONSIGNACION.CONS_ID%TYPE,
P_CONS_REGISTRADOPOR IN CONSIGNACION.CONS_REGISTRADOPOR%TYPE,
P_CONS_PROCESOAUDITORIA IN CONSIGNACION.CONS_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_CONSIGNACION(
CONS_COMPROINGRESO,
CONS_ID,
BANC_ID,
MUNI_ID,
DEPA_ID,
CONS_VALOR,
CONS_FECHA,
CONS_NUMERO,
CONS_REGISTRADOPOR,
CONS_FECHACAMBIO,
CONS_PROCESOAUDITORIA,
SOLI_ID,
CONS_OPERACION
)
SELECT
CONS_COMPROINGRESO,
CONS_ID,
BANC_ID,
MUNI_ID,
DEPA_ID,
CONS_VALOR,
CONS_FECHA,
CONS_NUMERO,
P_CONS_REGISTRADOPOR,
SYSDATE,
P_CONS_PROCESOAUDITORIA,
SOLI_ID,
'D'
FROM TRAMITE.CONSIGNACION WHERE CONS_ID = P_CONS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.CONSIGNACION WHERE CONS_ID = P_CONS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.departamento (
    depa_id                VARCHAR2(30 BYTE) NOT NULL,
    depa_nombre            VARCHAR2(100 BYTE) NOT NULL,
    depa_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    depa_fechacambio       DATE NOT NULL,
    depa_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    terr_id                NUMBER(9)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.departamento IS
    'Almacena los departamentos de Colombia (TABLA NO GESTIONABLE)';

COMMENT ON COLUMN tramite.departamento.depa_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.departamento.depa_nombre IS
    'ALMACENA EL NOMBRE DEL DEPARTAMENTO';

COMMENT ON COLUMN tramite.departamento.depa_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.departamento.depa_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.departamento.depa_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_depa_depa_nombre ON
    tramite.departamento (
        depa_nombre
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_depa ON
    tramite.departamento (
        depa_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.departamento
    ADD CONSTRAINT pk_depa PRIMARY KEY ( depa_id )
        USING INDEX tramite.pk_depa;

CREATE TABLE tramite.aud_departamento (
    depa_id                VARCHAR2(30 BYTE),
    depa_nombre            VARCHAR2(100 BYTE),
    depa_registradopor     VARCHAR2(30 BYTE),
    depa_fechacambio       DATE,
    depa_procesoauditoria  VARCHAR2(300 BYTE),
    depa_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_DEPARTAMENTO (
P_DEPA_ID IN DEPARTAMENTO.DEPA_ID%TYPE,
P_DEPA_REGISTRADOPOR IN DEPARTAMENTO.DEPA_REGISTRADOPOR%TYPE,
P_DEPA_PROCESOAUDITORIA IN DEPARTAMENTO.DEPA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_DEPARTAMENTO(
DEPA_ID,
DEPA_NOMBRE,
DEPA_REGISTRADOPOR,
DEPA_FECHACAMBIO,
DEPA_PROCESOAUDITORIA,
DEPA_OPERACION
)
SELECT
DEPA_ID,
DEPA_NOMBRE,
P_DEPA_REGISTRADOPOR,
SYSDATE,
P_DEPA_PROCESOAUDITORIA,
'D'
FROM TRAMITE.DEPARTAMENTO WHERE DEPA_ID = P_DEPA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.DEPARTAMENTO WHERE DEPA_ID = P_DEPA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.dianohabilcarga (
    dnhc_id                NUMBER(30) NOT NULL,
    dnhc_fecha             DATE NOT NULL,
    dnhc_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    dnhc_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    dnhc_fechacambio       DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.dnhc_fecha_uk ON
    tramite.dianohabilcarga (
        dnhc_fecha
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.dnhc_pk ON
    tramite.dianohabilcarga (
        dnhc_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.dianohabilcarga
    ADD CONSTRAINT dnhc_pk PRIMARY KEY ( dnhc_id )
        USING INDEX tramite.dnhc_pk;

ALTER TABLE tramite.dianohabilcarga
    ADD CONSTRAINT dnhc_fecha_uk UNIQUE ( dnhc_fecha )
        USING INDEX tramite.dnhc_fecha_uk;

CREATE TABLE tramite.aud_dianohabilcarga (
    dnhc_id                NUMBER(30),
    dnhc_fecha             DATE,
    dnhc_procesoauditoria  VARCHAR2(300 BYTE),
    dnhc_registradopor     VARCHAR2(30 BYTE),
    dnhc_fechacambio       DATE,
    dnhc_operacion         VARCHAR2(1 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_DIANOHABILCARGA (
P_DNHC_ID IN DIANOHABILCARGA.DNHC_ID%TYPE,
P_DNHC_REGISTRADOPOR IN DIANOHABILCARGA.DNHC_REGISTRADOPOR%TYPE,
P_DNHC_PROCESOAUDITORIA IN DIANOHABILCARGA.DNHC_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_DIANOHABILCARGA(
DNHC_ID,
DNHC_FECHA,
DNHC_PROCESOAUDITORIA,
DNHC_REGISTRADOPOR,
DNHC_FECHACAMBIO,
DNHC_OPERACION
)
SELECT
DNHC_ID,
DNHC_FECHA,
P_DNHC_PROCESOAUDITORIA,
P_DNHC_REGISTRADOPOR,
SYSDATE,
'D'
FROM TRAMITE.DIANOHABILCARGA WHERE DNHC_ID = P_DNHC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.DIANOHABILCARGA WHERE DNHC_ID = P_DNHC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.encuesta (
    encu_id                     NUMBER(30) NOT NULL,
    pers_id                     NUMBER(30),
    encu_rango_edad             VARCHAR2(15 BYTE),
    encu_nivel_educativo        VARCHAR2(15 BYTE),
    encu_clasificacion_per_jud  VARCHAR2(20 BYTE),
    encu_clasificacion_otra     VARCHAR2(100 BYTE),
    encu_calificacion_servicio  VARCHAR2(15 BYTE),
    encu_tipo_perju             VARCHAR2(15 BYTE),
    encu_observacion            VARCHAR2(300 BYTE),
    encu_procesoauditoria       VARCHAR2(50 BYTE),
    encu_fechacambio            DATE DEFAULT sysdate
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.encu_id_pk ON
    tramite.encuesta (
        encu_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.encuesta
    ADD CONSTRAINT encu_id_pk PRIMARY KEY ( encu_id )
        USING INDEX tramite.encu_id_pk;

CREATE TABLE tramite.aud_encuesta (
    encu_id                NUMBER NOT NULL,
    encu_respuesta         VARCHAR2(15 BYTE) NOT NULL,
    encu_observacion       VARCHAR2(500 BYTE),
    encu_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    encu_fechacambio       DATE NOT NULL,
    encu_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    encu_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_ENCUESTA (
P_ENCU_ID IN ENCUESTA.ENCU_ID%TYPE,
P_ENCU_REGISTRADOPOR IN ENCUESTA.ENCU_REGISTRADOPOR%TYPE,
P_ENCU_PROCESOAUDITORIA IN ENCUESTA.ENCU_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_ENCUESTA(
ENCU_ID,
ENCU_RESPUESTA,
ENCU_OBSERVACION,
ENCU_REGISTRADOPOR,
ENCU_FECHACAMBIO,
ENCU_PROCESOAUDITORIA,
ENCU_OPERACION
)
SELECT
ENCU_ID,
ENCU_RESPUESTA,
ENCU_OBSERVACION,
P_ENCU_REGISTRADOPOR,
SYSDATE,
P_ENCU_PROCESOAUDITORIA,
'D'
FROM TRAMITE.ENCUESTA WHERE ENCU_ID = P_ENCU_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.ENCUESTA WHERE ENCU_ID = P_ENCU_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_estadosolicitud (
    esso_id                NUMBER(30),
    esso_descripcion       VARCHAR2(200 BYTE),
    esso_tipoestado        VARCHAR2(30 BYTE),
    esso_registradopor     VARCHAR2(30 BYTE),
    esso_fechacambio       DATE,
    esso_procesoauditoria  VARCHAR2(300 BYTE),
    esso_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_ESTADOSOLICITUD (
P_ESSO_ID IN ESTADOSOLICITUD.ESSO_ID%TYPE,
P_ESSO_REGISTRADOPOR IN ESTADOSOLICITUD.ESSO_REGISTRADOPOR%TYPE,
P_ESSO_PROCESOAUDITORIA IN ESTADOSOLICITUD.ESSO_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_ESTADOSOLICITUD(
ESSO_ID,
ESSO_DESCRIPCION,
ESSO_TIPOESTADO,
ESSO_REGISTRADOPOR,
ESSO_FECHACAMBIO,
ESSO_PROCESOAUDITORIA,
ESSO_OPERACION
)
SELECT
ESSO_ID,
ESSO_DESCRIPCION,
ESSO_TIPOESTADO,
P_ESSO_REGISTRADOPOR,
SYSDATE,
P_ESSO_PROCESOAUDITORIA,
'D'
FROM TRAMITE.ESTADOSOLICITUD WHERE ESSO_ID = P_ESSO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.ESTADOSOLICITUD WHERE ESSO_ID = P_ESSO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.estadosolicitudsiguiente (
    esso_id_origen         NUMBER(30) NOT NULL,
    esso_id_destino        NUMBER(30) NOT NULL,
    essi_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    essi_fechacambio       DATE NOT NULL,
    essi_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    tram_id                NUMBER(30) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.estadosolicitudsiguiente IS
    'Almacena el estado siguiente de un estado actual de una solicitud de tramite';

COMMENT ON COLUMN tramite.estadosolicitudsiguiente.esso_id_origen IS
    'ALMACENA EL IDENTIFICADOR DEL ESTADO QUE PRECEDE A OTRAS TABLAS';

COMMENT ON COLUMN tramite.estadosolicitudsiguiente.esso_id_destino IS
    'ALMACENA EL IDENTIFICADOR DEL ESTADO QUE PRECEDE A OTRAS TABLAS';

COMMENT ON COLUMN tramite.estadosolicitudsiguiente.essi_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.estadosolicitudsiguiente.essi_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.estadosolicitudsiguiente.essi_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.estadosolicitudsiguiente_pk ON
    tramite.estadosolicitudsiguiente (
        esso_id_origen
    ASC,
        esso_id_destino
    ASC,
        tram_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.estadosolicitudsiguiente
    ADD CONSTRAINT estadosolicitudsiguiente_pk PRIMARY KEY ( esso_id_origen,
                                                             esso_id_destino,
                                                             tram_id )
        USING INDEX tramite.estadosolicitudsiguiente_pk;

CREATE TABLE tramite.aud_estadosolicitudsiguiente (
    esso_id_origen         NUMBER(30),
    esso_id_destino        NUMBER(30),
    essi_registradopor     VARCHAR2(30 BYTE),
    essi_fechacambio       DATE,
    essi_procesoauditoria  VARCHAR2(300 BYTE),
    essi_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_ESTADOSOLSIG (
P_ESSO_ID_ORIGEN IN ESTADOSOLICITUDSIGUIENTE.ESSO_ID_ORIGEN%TYPE,
P_ESSO_ID_DESTINO IN ESTADOSOLICITUDSIGUIENTE.ESSO_ID_DESTINO%TYPE,
P_ESSI_REGISTRADOPOR IN ESTADOSOLICITUDSIGUIENTE.ESSI_REGISTRADOPOR%TYPE,
P_ESSI_PROCESOAUDITORIA IN ESTADOSOLICITUDSIGUIENTE.ESSI_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_ESTADOSOLICITUDSIGUIENTE(
ESSO_ID_ORIGEN,
ESSO_ID_DESTINO,
ESSI_REGISTRADOPOR,
ESSI_FECHACAMBIO,
ESSI_PROCESOAUDITORIA,
ESSI_OPERACION
)
SELECT
ESSO_ID_ORIGEN,
ESSO_ID_DESTINO,
P_ESSI_REGISTRADOPOR,
SYSDATE,
P_ESSI_PROCESOAUDITORIA,
'D'
FROM TRAMITE.ESTADOSOLICITUDSIGUIENTE WHERE ESSO_ID_ORIGEN = P_ESSO_ID_ORIGEN AND
ESSO_ID_DESTINO = P_ESSO_ID_DESTINO;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.ESTADOSOLICITUDSIGUIENTE WHERE ESSO_ID_ORIGEN = P_ESSO_ID_ORIGEN AND
ESSO_ID_DESTINO = P_ESSO_ID_DESTINO;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.municipio (
    muni_id                VARCHAR2(30 BYTE) NOT NULL,
    depa_id                VARCHAR2(30 BYTE) NOT NULL,
    muni_nombre            VARCHAR2(100 BYTE) NOT NULL,
    muni_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    muni_fechacambio       DATE NOT NULL,
    muni_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.municipio IS
    'Almacena los municipios de Colombia (TABLA NO GESTIONABLE)';

COMMENT ON COLUMN tramite.municipio.muni_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.municipio.depa_id IS
    'ALMACENA EL IDENTIFICADOR DEL DEPARTAMENTO';

COMMENT ON COLUMN tramite.municipio.muni_nombre IS
    'ALMACENA EL NOMBRE DEL MUNICIPIO';

COMMENT ON COLUMN tramite.municipio.muni_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.municipio.muni_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.municipio.muni_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.muni_uk ON
    tramite.municipio (
        depa_id
    ASC,
        muni_nombre
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_muni ON
    tramite.municipio (
        muni_id
    ASC,
        depa_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.municipio
    ADD CONSTRAINT pk_muni PRIMARY KEY ( muni_id,
                                         depa_id )
        USING INDEX tramite.pk_muni;

ALTER TABLE tramite.municipio
    ADD CONSTRAINT muni_uk UNIQUE ( depa_id,
                                    muni_nombre )
        USING INDEX tramite.muni_uk;

CREATE TABLE tramite.aud_municipio (
    muni_id                VARCHAR2(30 BYTE),
    depa_id                VARCHAR2(30 BYTE),
    muni_nombre            VARCHAR2(100 BYTE),
    muni_registradopor     VARCHAR2(30 BYTE),
    muni_fechacambio       TIMESTAMP,
    muni_procesoauditoria  VARCHAR2(300 BYTE),
    muni_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 262144 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_MUNICIPIO (
P_MUNI_ID IN MUNICIPIO.MUNI_ID%TYPE,
P_DEPA_ID IN MUNICIPIO.DEPA_ID%TYPE,
P_MUNI_REGISTRADOPOR IN MUNICIPIO.MUNI_REGISTRADOPOR%TYPE,
P_MUNI_PROCESOAUDITORIA IN MUNICIPIO.MUNI_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_MUNICIPIO(
MUNI_ID,
DEPA_ID,
MUNI_NOMBRE,
MUNI_REGISTRADOPOR,
MUNI_FECHACAMBIO,
MUNI_PROCESOAUDITORIA,
MUNI_OPERACION
)
SELECT
MUNI_ID,
DEPA_ID,
MUNI_NOMBRE,
P_MUNI_REGISTRADOPOR,
SYSDATE,
P_MUNI_PROCESOAUDITORIA,
'D'
FROM TRAMITE.MUNICIPIO WHERE MUNI_ID = P_MUNI_ID AND
DEPA_ID = P_DEPA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.MUNICIPIO WHERE MUNI_ID = P_MUNI_ID AND
DEPA_ID = P_DEPA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_parametrizacion (
    para_id                     NUMBER(30),
    para_pagoelectronico        VARCHAR2(1 BYTE),
    para_impresionrecibopag     VARCHAR2(1 BYTE),
    para_solitransportecarg     VARCHAR2(1 BYTE),
    para_soliusozonacarrete     VARCHAR2(1 BYTE),
    para_solicierrevia          VARCHAR2(1 BYTE),
    para_solipazysalvo          VARCHAR2(1 BYTE),
    para_registradopor          VARCHAR2(30 BYTE),
    para_fechacambio            DATE,
    para_procesoauditoria       VARCHAR2(300 BYTE),
    para_correoremitente        VARCHAR2(100 BYTE),
    para_operacion              VARCHAR2(1 BYTE) NOT NULL,
    para_ancho                  VARCHAR2(100 BYTE),
    para_alto                   VARCHAR2(100 BYTE),
    para_longitudsobresaliente  VARCHAR2(100 BYTE),
    para_leyenda                VARCHAR2(4000 BYTE),
    para_redvial                VARCHAR2(100 BYTE),
    para_urlaplicativo          VARCHAR2(500 BYTE) NOT NULL,
    para_esfitramitecarga       NUMBER(30),
    para_peso                   VARCHAR2(100 BYTE),
    para_cargo                  VARCHAR2(100 BYTE),
    para_funcionario            VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PARAMETRIZACION (
P_PARA_ID IN PARAMETRIZACION.PARA_ID%TYPE,
P_PARA_REGISTRADOPOR IN PARAMETRIZACION.PARA_REGISTRADOPOR%TYPE,
P_PARA_PROCESOAUDITORIA IN PARAMETRIZACION.PARA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO TRAMITE.AUD_PARAMETRIZACION(
PARA_REDVIAL,
PARA_ANCHO,
PARA_ALTO,
PARA_LONGITUDSOBRESALIENTE,
PARA_LEYENDA,
PARA_URLAPLICATIVO,
PARA_ID,
PARA_PAGOELECTRONICO,
PARA_IMPRESIONRECIBOPAG,
PARA_SOLITRANSPORTECARG,
PARA_SOLIUSOZONACARRETE,
PARA_SOLICIERREVIA,
PARA_SOLIPAZYSALVO,
PARA_REGISTRADOPOR,
PARA_FECHACAMBIO,
PARA_PROCESOAUDITORIA,
PARA_CORREOREMITENTE,
PARA_OPERACION,
PARA_ESFITRAMITECARGA,
PARA_PESO,
PARA_CARGO,
PARA_FUNCIONARIO
)
SELECT
PARA_REDVIAL,
PARA_ANCHO,
PARA_ALTO,
PARA_LONGITUDSOBRESALIENTE,
PARA_LEYENDA,
PARA_URLAPLICATIVO,
PARA_ID,
PARA_PAGOELECTRONICO,
PARA_IMPRESIONRECIBOPAG,
PARA_SOLITRANSPORTECARG,
PARA_SOLIUSOZONACARRETE,
PARA_SOLICIERREVIA,
PARA_SOLIPAZYSALVO,
P_PARA_REGISTRADOPOR,
SYSDATE,
P_PARA_PROCESOAUDITORIA,
PARA_CORREOREMITENTE,
'D',
PARA_ESFITRAMITECARGA,
PARA_PESO,
PARA_CARGO,
PARA_FUNCIONARIO
FROM TRAMITE.PARAMETRIZACION WHERE PARA_ID = P_PARA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PARAMETRIZACION WHERE PARA_ID = P_PARA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.persona (
    pers_id                  NUMBER(30) NOT NULL,
    tido_id                  NUMBER(30) NOT NULL,
    muni_id                  VARCHAR2(30 BYTE) NOT NULL,
    depa_id                  VARCHAR2(30 BYTE) NOT NULL,
    pers_documentoidentidad  VARCHAR2(100 BYTE) NOT NULL,
    pers_direccion           VARCHAR2(100 BYTE) NOT NULL,
    pers_telefono            VARCHAR2(100 BYTE),
    pers_correoelectronico   VARCHAR2(100 BYTE),
    pers_fax                 VARCHAR2(100 BYTE),
    pers_registradopor       VARCHAR2(30 BYTE) NOT NULL,
    pers_fechacambio         DATE NOT NULL,
    pers_procesoauditoria    VARCHAR2(300 BYTE) NOT NULL,
    pers_validado            NUMBER(*, 0) DEFAULT 0
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.persona IS
    'Almacena las personas que son usuarios del sistema';

COMMENT ON COLUMN tramite.persona.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.persona.tido_id IS
    'ALMACENA EL IDENTIFICADOR DEL TIPO DOCUMENTO';

COMMENT ON COLUMN tramite.persona.muni_id IS
    'ALMACENA EL IDENTIFICADOR DEL MUNICIPIO';

COMMENT ON COLUMN tramite.persona.depa_id IS
    'ALMACENA EL IDENTIFICADOR DEL DEPARTAMENTO';

COMMENT ON COLUMN tramite.persona.pers_documentoidentidad IS
    'ALMACENA EL NUMERO DEL DOCUMENTO DE IDENTIFICACION';

COMMENT ON COLUMN tramite.persona.pers_direccion IS
    'ALMACENA LA DIRECCION';

COMMENT ON COLUMN tramite.persona.pers_telefono IS
    'ALMACENA EL NUMERO DE TELEFONO';

COMMENT ON COLUMN tramite.persona.pers_correoelectronico IS
    'ALMACENA EL CORREO ELECTRONICO';

COMMENT ON COLUMN tramite.persona.pers_fax IS
    'ALMACENA EL NUMERO DE FAX';

COMMENT ON COLUMN tramite.persona.pers_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.persona.pers_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.persona.pers_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_pers ON
    tramite.persona (
        pers_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.persona TO interventor;

ALTER TABLE tramite.persona
    ADD CONSTRAINT pk_pers PRIMARY KEY ( pers_id )
        USING INDEX tramite.pk_pers;

CREATE TABLE tramite.aud_persona (
    pers_id                  NUMBER(30),
    tido_id                  NUMBER(30),
    muni_id                  VARCHAR2(30 BYTE),
    depa_id                  VARCHAR2(30 BYTE),
    pers_documentoidentidad  VARCHAR2(100 BYTE),
    pers_direccion           VARCHAR2(100 BYTE),
    pers_telefono            VARCHAR2(100 BYTE),
    pers_correoelectronico   VARCHAR2(100 BYTE),
    pers_fax                 VARCHAR2(100 BYTE),
    pers_registradopor       VARCHAR2(30 BYTE),
    pers_fechacambio         DATE,
    pers_procesoauditoria    VARCHAR2(300 BYTE),
    pers_operacion           VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 196608 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PERSONA (
P_PERS_ID IN PERSONA.PERS_ID%TYPE,
P_PERS_REGISTRADOPOR IN PERSONA.PERS_REGISTRADOPOR%TYPE,
P_PERS_PROCESOAUDITORIA IN PERSONA.PERS_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PERSONA(
PERS_ID,
TIDO_ID,
MUNI_ID,
DEPA_ID,
PERS_DOCUMENTOIDENTIDAD,
PERS_DIRECCION,
PERS_TELEFONO,
PERS_CORREOELECTRONICO,
PERS_FAX,
PERS_REGISTRADOPOR,
PERS_FECHACAMBIO,
PERS_PROCESOAUDITORIA,
PERS_OPERACION
)
SELECT
PERS_ID,
TIDO_ID,
MUNI_ID,
DEPA_ID,
PERS_DOCUMENTOIDENTIDAD,
PERS_DIRECCION,
PERS_TELEFONO,
PERS_CORREOELECTRONICO,
PERS_FAX,
P_PERS_REGISTRADOPOR,
SYSDATE,
P_PERS_PROCESOAUDITORIA,
'D'
FROM TRAMITE.PERSONA WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PERSONA WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.personajuridica (
    pers_id                   NUMBER(30) NOT NULL,
    pers_idpersonanatural     NUMBER(30),
    peju_razonsocial          VARCHAR2(100 BYTE) NOT NULL,
    peju_codigorepresentante  VARCHAR2(50 BYTE),
    peju_registradopor        VARCHAR2(30 BYTE) NOT NULL,
    peju_fechacambio          DATE NOT NULL,
    peju_procesoauditoria     VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.personajuridica IS
    'Almacena las personas juridicas que son usuarios del sistema';

COMMENT ON COLUMN tramite.personajuridica.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA PERSONA';

COMMENT ON COLUMN tramite.personajuridica.pers_idpersonanatural IS
    'ALMACENA EL IDENTIFICADOR DE LA PERSONA NATURAL PARA EL REPRESENTANTE LEGAL';

COMMENT ON COLUMN tramite.personajuridica.peju_razonsocial IS
    'ALMACENA EL NOMBRE DE LA RAZON SOCIAL';

COMMENT ON COLUMN tramite.personajuridica.peju_codigorepresentante IS
    'ALMACENA EL CODIGO DEL REPRESENTANTE LEGAL';

COMMENT ON COLUMN tramite.personajuridica.peju_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.personajuridica.peju_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personajuridica.peju_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_peju ON
    tramite.personajuridica (
        pers_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.personajuridica TO tramite_consulta;

ALTER TABLE tramite.personajuridica
    ADD CONSTRAINT pk_peju PRIMARY KEY ( pers_id )
        USING INDEX tramite.pk_peju;

CREATE TABLE tramite.aud_personajuridica (
    pers_id                   NUMBER(30),
    pers_idpersonanatural     NUMBER(30),
    peju_razonsocial          VARCHAR2(100 BYTE),
    peju_codigorepresentante  VARCHAR2(50 BYTE),
    peju_registradopor        VARCHAR2(30 BYTE),
    peju_fechacambio          DATE,
    peju_procesoauditoria     VARCHAR2(300 BYTE),
    peju_operacion            VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PERSONAJURIDICA (
P_PERS_ID IN PERSONAJURIDICA.PERS_ID%TYPE,
P_PEJU_REGISTRADOPOR IN PERSONAJURIDICA.PEJU_REGISTRADOPOR%TYPE,
P_PEJU_PROCESOAUDITORIA IN PERSONAJURIDICA.PEJU_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PERSONAJURIDICA(
PERS_ID,
PERS_IDPERSONANATURAL,
PEJU_RAZONSOCIAL,
PEJU_CODIGOREPRESENTANTE,
PEJU_REGISTRADOPOR,
PEJU_FECHACAMBIO,
PEJU_PROCESOAUDITORIA,
PEJU_OPERACION
)
SELECT
PERS_ID,
PERS_IDPERSONANATURAL,
PEJU_RAZONSOCIAL,
PEJU_CODIGOREPRESENTANTE,
P_PEJU_REGISTRADOPOR,
SYSDATE,
P_PEJU_PROCESOAUDITORIA,
'D'
FROM TRAMITE.PERSONAJURIDICA WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PERSONAJURIDICA WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.personanatural (
    pers_id                NUMBER(30) NOT NULL,
    pena_primernombre      VARCHAR2(50 BYTE) NOT NULL,
    pena_segundonombre     VARCHAR2(50 BYTE),
    pena_primerapellido    VARCHAR2(50 BYTE) NOT NULL,
    pena_segundoapellido   VARCHAR2(50 BYTE),
    pena_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    pena_fechacambio       DATE NOT NULL,
    pena_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.personanatural IS
    'Almacena las personas naturales que son usuarios del sistema';

COMMENT ON COLUMN tramite.personanatural.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA PERSONA';

COMMENT ON COLUMN tramite.personanatural.pena_primernombre IS
    'ALMACENA EL PRIMER NOMBRE DE PERSONA';

COMMENT ON COLUMN tramite.personanatural.pena_segundonombre IS
    'ALMACENA EL SEGUNDO NOMBRE DE LA PERSONA';

COMMENT ON COLUMN tramite.personanatural.pena_primerapellido IS
    'ALMACENA EL PRIMER APELLIDO DE LA PERSONA';

COMMENT ON COLUMN tramite.personanatural.pena_segundoapellido IS
    'ALMACENA EL SEGUNDO APELLIDO DE LA PERSONA';

COMMENT ON COLUMN tramite.personanatural.pena_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.personanatural.pena_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personanatural.pena_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_pena ON
    tramite.personanatural (
        pers_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.personanatural TO tramite_consulta;

ALTER TABLE tramite.personanatural
    ADD CONSTRAINT pk_pena PRIMARY KEY ( pers_id )
        USING INDEX tramite.pk_pena;

CREATE TABLE tramite.aud_personanatural (
    pers_id                NUMBER(30),
    pena_primernombre      VARCHAR2(50 BYTE),
    pena_segundonombre     VARCHAR2(50 BYTE),
    pena_primerapellido    VARCHAR2(50 BYTE),
    pena_segundoapellido   VARCHAR2(50 BYTE),
    pena_registradopor     VARCHAR2(30 BYTE),
    pena_fechacambio       DATE,
    pena_procesoauditoria  VARCHAR2(300 BYTE),
    pena_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PERSONANATURAL (
P_PERS_ID IN PERSONANATURAL.PERS_ID%TYPE,
P_PENA_REGISTRADOPOR IN PERSONANATURAL.PENA_REGISTRADOPOR%TYPE,
P_PENA_PROCESOAUDITORIA IN PERSONANATURAL.PENA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PERSONANATURAL(
PENA_REGISTRADOPOR,
PENA_FECHACAMBIO,
PENA_PROCESOAUDITORIA,
PERS_ID,
PENA_PRIMERNOMBRE,
PENA_SEGUNDONOMBRE,
PENA_PRIMERAPELLIDO,
PENA_SEGUNDOAPELLIDO,
PENA_OPERACION
)
SELECT
P_PENA_REGISTRADOPOR,
SYSDATE,
P_PENA_PROCESOAUDITORIA,
PERS_ID,
PENA_PRIMERNOMBRE,
PENA_SEGUNDONOMBRE,
PENA_PRIMERAPELLIDO,
PENA_SEGUNDOAPELLIDO,
'D'
FROM TRAMITE.PERSONANATURAL WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PERSONANATURAL WHERE PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.personaremolque (
    remo_id                NUMBER(30) NOT NULL,
    pere_fechacambio       DATE NOT NULL,
    pere_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    pere_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    pers_id                NUMBER(30) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.personaremolque IS
    'Almacena los remolques de una persona cliente del sistema';

COMMENT ON COLUMN tramite.personaremolque.remo_id IS
    'ALMACENA EL IDENTIFICADOR DEL REMOLQUE';

COMMENT ON COLUMN tramite.personaremolque.pere_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personaremolque.pere_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.personaremolque.pere_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personaremolque.pers_id IS
    'ALMACENA EL IDENTIDIFICADOR DE LA PERSONA';

CREATE UNIQUE INDEX tramite.pk_pere ON
    tramite.personaremolque (
        remo_id
    ASC,
        pers_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.personaremolque
    ADD CONSTRAINT pk_pere PRIMARY KEY ( remo_id,
                                         pers_id )
        USING INDEX tramite.pk_pere;

CREATE TABLE tramite.aud_personaremolque (
    remo_id                NUMBER(30),
    pere_fechacambio       DATE,
    pere_registradopor     VARCHAR2(30 BYTE),
    pere_procesoauditoria  VARCHAR2(300 BYTE),
    pers_id                NUMBER(30),
    pere_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PERSONAREMOLQUE (
P_REMO_ID IN PERSONAREMOLQUE.REMO_ID%TYPE,
P_PERS_ID IN PERSONAREMOLQUE.PERS_ID%TYPE,
P_PERE_REGISTRADOPOR IN PERSONAREMOLQUE.PERE_REGISTRADOPOR%TYPE,
P_PERE_PROCESOAUDITORIA IN PERSONAREMOLQUE.PERE_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PERSONAREMOLQUE(
REMO_ID,
PERE_FECHACAMBIO,
PERE_REGISTRADOPOR,
PERE_PROCESOAUDITORIA,
PERS_ID,
PERE_OPERACION
)
SELECT
REMO_ID,
SYSDATE,
P_PERE_REGISTRADOPOR,
P_PERE_PROCESOAUDITORIA,
PERS_ID,
'D'
FROM TRAMITE.PERSONAREMOLQUE WHERE REMO_ID = P_REMO_ID AND
PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PERSONAREMOLQUE WHERE REMO_ID = P_REMO_ID AND
PERS_ID = P_PERS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.personavehiculo (
    peve_fechacambio       DATE NOT NULL,
    peve_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    peve_procesoauditoria  VARCHAR2(300 BYTE),
    pers_id                NUMBER(30) NOT NULL,
    vehi_id                NUMBER(30) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.personavehiculo IS
    'Almacena los vehiculos de una persona cliente del sistema';

COMMENT ON COLUMN tramite.personavehiculo.peve_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personavehiculo.peve_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.personavehiculo.peve_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.personavehiculo.pers_id IS
    'ALMACENA EL IDENTIDIFICADOR DE LA PERSONA';

COMMENT ON COLUMN tramite.personavehiculo.vehi_id IS
    'ALMACENA EL IDENTIFICADOR DEL VEHICULO';

CREATE UNIQUE INDEX tramite.pk_peve ON
    tramite.personavehiculo (
        pers_id
    ASC,
        vehi_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.personavehiculo
    ADD CONSTRAINT pk_peve PRIMARY KEY ( pers_id,
                                         vehi_id )
        USING INDEX tramite.pk_peve;

CREATE TABLE tramite.aud_personavehiculo (
    peve_fechacambio       DATE,
    peve_registradopor     VARCHAR2(30 BYTE),
    peve_procesoauditoria  VARCHAR2(300 BYTE),
    pers_id                NUMBER(30),
    vehi_id                NUMBER(30),
    peve_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PERSONAVEHICULO (
P_PERS_ID IN PERSONAVEHICULO.PERS_ID%TYPE,
P_VEHI_ID IN PERSONAVEHICULO.VEHI_ID%TYPE,
P_PEVE_REGISTRADOPOR IN PERSONAVEHICULO.PEVE_REGISTRADOPOR%TYPE,
P_PEVE_PROCESOAUDITORIA IN PERSONAVEHICULO.PEVE_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PERSONAVEHICULO(
PEVE_FECHACAMBIO,
PEVE_REGISTRADOPOR,
PEVE_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
PEVE_OPERACION
)
SELECT
SYSDATE,
P_PEVE_REGISTRADOPOR,
P_PEVE_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
'D'
FROM TRAMITE.PERSONAVEHICULO WHERE PERS_ID = P_PERS_ID AND
VEHI_ID = P_VEHI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PERSONAVEHICULO WHERE PERS_ID = P_PERS_ID AND
VEHI_ID = P_VEHI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.programacionevento (
    prev_id                NUMBER(30) NOT NULL,
    prev_municipiosalida   VARCHAR2(100 BYTE) NOT NULL,
    prev_municipiollegada  VARCHAR2(100 BYTE) NOT NULL,
    prev_fecha             DATE NOT NULL,
    prev_horasalida        VARCHAR2(30 BYTE) NOT NULL,
    prev_horallegada       VARCHAR2(30 BYTE) NOT NULL,
    prev_lugarsalida       VARCHAR2(100 BYTE) NOT NULL,
    prev_lugarllegada      VARCHAR2(100 BYTE) NOT NULL,
    prev_fechacambio       DATE NOT NULL,
    prev_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    prev_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    soli_id                NUMBER(30) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.programacionevento IS
    'Almacena el cronograma del recorrido del evento, solicitado en el tramite Cierre Parcial de Vias Para Eventos Deportivos';

COMMENT ON COLUMN tramite.programacionevento.prev_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.programacionevento.prev_municipiosalida IS
    'ALMACENA EL MUNICIPIO DE SALIDA';

COMMENT ON COLUMN tramite.programacionevento.prev_municipiollegada IS
    'ALMACENA EL MUNICIPIO DE LLEGADA';

COMMENT ON COLUMN tramite.programacionevento.prev_fecha IS
    'ALMACENA LA FECHA DEL EVENTO';

COMMENT ON COLUMN tramite.programacionevento.prev_horasalida IS
    'ALMACENA LA HORA DE SALIDA DEL EVENTO';

COMMENT ON COLUMN tramite.programacionevento.prev_horallegada IS
    'ALMACENA LA HORA DE LLEGADA DEL EVENTO';

COMMENT ON COLUMN tramite.programacionevento.prev_lugarsalida IS
    'ALMACENA EL LUGAR DE SALIDA DEL EVENTO';

COMMENT ON COLUMN tramite.programacionevento.prev_lugarllegada IS
    'ALMACENA EL LUGAR DE LLEGADA DEL EVENTO';

COMMENT ON COLUMN tramite.programacionevento.prev_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.programacionevento.prev_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.programacionevento.prev_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.programacionevento.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA SOLICITUDCIERREVIA';

CREATE UNIQUE INDEX tramite.pk_prev ON
    tramite.programacionevento (
        prev_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.programacionevento
    ADD CONSTRAINT pk_prev PRIMARY KEY ( prev_id )
        USING INDEX tramite.pk_prev;

CREATE TABLE tramite.aud_programacionevento (
    soli_id                NUMBER(30),
    prev_municipiosalida   VARCHAR2(100 BYTE),
    prev_municipiollegada  VARCHAR2(100 BYTE),
    prev_fecha             DATE,
    prev_horasalida        VARCHAR2(30 BYTE),
    prev_horallegada       VARCHAR2(30 BYTE),
    prev_lugarsalida       VARCHAR2(100 BYTE),
    prev_lugarllegada      VARCHAR2(100 BYTE),
    prev_fechacambio       DATE,
    prev_procesoauditoria  VARCHAR2(300 BYTE),
    prev_registradopor     VARCHAR2(30 BYTE),
    prev_operacion         VARCHAR2(1 BYTE) NOT NULL,
    prev_id                NUMBER(30)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_PROGEVENTO (
P_PREV_ID IN PROGRAMACIONEVENTO.PREV_ID%TYPE,
P_PREV_REGISTRADOPOR IN PROGRAMACIONEVENTO.PREV_REGISTRADOPOR%TYPE,
P_PREV_PROCESOAUDITORIA IN PROGRAMACIONEVENTO.PREV_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_PROGRAMACIONEVENTO(
PREV_ID,
PREV_MUNICIPIOSALIDA,
PREV_MUNICIPIOLLEGADA,
PREV_FECHA,
PREV_HORASALIDA,
PREV_HORALLEGADA,
PREV_LUGARSALIDA,
PREV_LUGARLLEGADA,
PREV_FECHACAMBIO,
PREV_PROCESOAUDITORIA,
PREV_REGISTRADOPOR,
SOLI_ID,
PREV_OPERACION
)
SELECT
PREV_ID,
PREV_MUNICIPIOSALIDA,
PREV_MUNICIPIOLLEGADA,
PREV_FECHA,
PREV_HORASALIDA,
PREV_HORALLEGADA,
PREV_LUGARSALIDA,
PREV_LUGARLLEGADA,
SYSDATE,
P_PREV_PROCESOAUDITORIA,
P_PREV_REGISTRADOPOR,
SOLI_ID,
'D'
FROM TRAMITE.PROGRAMACIONEVENTO WHERE PREV_ID = P_PREV_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.PROGRAMACIONEVENTO WHERE PREV_ID = P_PREV_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.remolque (
    remo_id                       NUMBER(30) NOT NULL,
    remo_placa                    VARCHAR2(50 BYTE) NOT NULL,
    remo_registradopor            VARCHAR2(30 BYTE) NOT NULL,
    remo_fechacambio              DATE NOT NULL,
    remo_procesoauditoria         VARCHAR2(300 BYTE) NOT NULL,
    remo_numero_ejes              NUMBER(*, 0),
    remo_numero_llantas_eje       NUMBER(*, 0),
    remo_presion_inflado_llantas  NUMBER(7, 2),
    remo_espropiedad              NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.remolque IS
    'Almacena los datos de los remolques';

COMMENT ON COLUMN tramite.remolque.remo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.remolque.remo_placa IS
    'ALMACENA LA PLACA DEL REMOLQUE';

COMMENT ON COLUMN tramite.remolque.remo_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.remolque.remo_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.remolque.remo_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_remo ON
    tramite.remolque (
        remo_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.remolque
    ADD CONSTRAINT pk_remo PRIMARY KEY ( remo_id )
        USING INDEX tramite.pk_remo;

CREATE TABLE tramite.aud_remolque (
    remo_id                NUMBER(30),
    remo_placa             VARCHAR2(50 BYTE),
    remo_registradopor     VARCHAR2(30 BYTE),
    remo_fechacambio       DATE,
    remo_procesoauditoria  VARCHAR2(300 BYTE),
    remo_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_REMOLQUE (
P_REMO_ID IN REMOLQUE.REMO_ID%TYPE,
P_REMO_REGISTRADOPOR IN REMOLQUE.REMO_REGISTRADOPOR%TYPE,
P_REMO_PROCESOAUDITORIA IN REMOLQUE.REMO_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_REMOLQUE(
REMO_ID,
REMO_PLACA,
REMO_REGISTRADOPOR,
REMO_FECHACAMBIO,
REMO_PROCESOAUDITORIA,
REMO_OPERACION
)
SELECT
REMO_ID,
REMO_PLACA,
P_REMO_REGISTRADOPOR,
SYSDATE,
P_REMO_PROCESOAUDITORIA,
'D'
FROM TRAMITE.REMOLQUE WHERE REMO_ID = P_REMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.REMOLQUE WHERE REMO_ID = P_REMO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_solicitudcargaremolque (
    remo_id                NUMBER(30),
    pers_id                NUMBER(30),
    soli_id                NUMBER(30),
    socr_fechacambio       DATE,
    socr_registradopor     VARCHAR2(30 BYTE),
    socr_procesoauditoria  VARCHAR2(300 BYTE),
    socr_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLCARGAREMO (
P_REMO_ID IN SOLICITUDCARGAREMOLQUE.REMO_ID%TYPE,
P_PERS_ID IN SOLICITUDCARGAREMOLQUE.PERS_ID%TYPE,
P_SOLI_ID IN SOLICITUDCARGAREMOLQUE.SOLI_ID%TYPE,
P_SOCR_REGISTRADOPOR IN SOLICITUDCARGAREMOLQUE.SOCR_REGISTRADOPOR%TYPE,
P_SOCR_PROCESOAUDITORIA IN SOLICITUDCARGAREMOLQUE.SOCR_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDCARGAREMOLQUE(
REMO_ID,
PERS_ID,
SOLI_ID,
SOCR_FECHACAMBIO,
SOCR_REGISTRADOPOR,
SOCR_PROCESOAUDITORIA,
SOCR_OPERACION
)
SELECT
REMO_ID,
PERS_ID,
SOLI_ID,
SYSDATE,
P_SOCR_REGISTRADOPOR,
P_SOCR_PROCESOAUDITORIA,
'D'
FROM TRAMITE.SOLICITUDCARGAREMOLQUE WHERE REMO_ID = P_REMO_ID AND
PERS_ID = P_PERS_ID AND
SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDCARGAREMOLQUE WHERE REMO_ID = P_REMO_ID AND
PERS_ID = P_PERS_ID AND
SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.solicitudcierrevia (
    soli_id                   NUMBER(30) NOT NULL,
    socv_nombreevento         VARCHAR2(200 BYTE) NOT NULL,
    socv_avaladopor           VARCHAR2(200 BYTE) NOT NULL,
    socv_recorridoprogramado  VARCHAR2(4000 BYTE) NOT NULL,
    socv_registradopor        VARCHAR2(30 BYTE) NOT NULL,
    socv_fechacambio          DATE NOT NULL,
    socv_procesoauditoria     VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudcierrevia IS
    'Almacena las solicitudes de tramites de Cierre Parcial de Vias Para Eventos Deportivos';

COMMENT ON COLUMN tramite.solicitudcierrevia.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_nombreevento IS
    'ALMACENA EL NOMBRE DEL EVENTO';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_avaladopor IS
    'ALMACENA EL NOMBRE DE QUIEN AVALA EL EVENTO';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_recorridoprogramado IS
    'ALMACENA EL RECORRIDO DEL EVENTO';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcierrevia.socv_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_socv ON
    tramite.solicitudcierrevia (
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudcierrevia
    ADD CONSTRAINT pk_socv PRIMARY KEY ( soli_id )
        USING INDEX tramite.pk_socv;

CREATE TABLE tramite.aud_solicitudcierrevia (
    soli_id                   NUMBER(30),
    socv_nombreevento         VARCHAR2(200 BYTE),
    socv_avaladopor           VARCHAR2(200 BYTE),
    socv_recorridoprogramado  VARCHAR2(4000 BYTE),
    socv_registradopor        VARCHAR2(30 BYTE),
    socv_fechacambio          DATE,
    socv_procesoauditoria     VARCHAR2(300 BYTE),
    socv_operacion            VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLCIERREVIA (
P_SOLI_ID IN SOLICITUDCIERREVIA.SOLI_ID%TYPE,
P_SOCV_REGISTRADOPOR IN SOLICITUDCIERREVIA.SOCV_REGISTRADOPOR%TYPE,
P_SOCV_PROCESOAUDITORIA IN SOLICITUDCIERREVIA.SOCV_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDCIERREVIA(
SOLI_ID,
SOCV_NOMBREEVENTO,
SOCV_AVALADOPOR,
SOCV_RECORRIDOPROGRAMADO,
SOCV_REGISTRADOPOR,
SOCV_FECHACAMBIO,
SOCV_PROCESOAUDITORIA,
SOCV_OPERACION
)
SELECT
SOLI_ID,
SOCV_NOMBREEVENTO,
SOCV_AVALADOPOR,
SOCV_RECORRIDOPROGRAMADO,
P_SOCV_REGISTRADOPOR,
SYSDATE,
P_SOCV_PROCESOAUDITORIA,
'D'
FROM TRAMITE.SOLICITUDCIERREVIA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDCIERREVIA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_solicitudcargaarchivo (
    scar_id                NUMBER(30),
    arch_id                NUMBER(30),
    soli_id                NUMBER(30),
    scar_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    scar_fechacambio       DATE NOT NULL,
    scar_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    scar_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLICARGAARCHIVO (
P_SCAR_ID IN SOLICITUDCARGAARCHIVO.SCAR_ID%TYPE,
P_SCAR_REGISTRADOPOR IN SOLICITUDCARGAARCHIVO.SCAR_REGISTRADOPOR%TYPE,
P_SCAR_PROCESOAUDITORIA IN SOLICITUDCARGAARCHIVO.SCAR_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDCARGAARCHIVO(
SCAR_ID,
ARCH_ID,
SOLI_ID,
SCAR_REGISTRADOPOR,
SCAR_FECHACAMBIO,
SCAR_PROCESOAUDITORIA,
SCAR_OPERACION
)
SELECT
SCAR_ID,
ARCH_ID,
SOLI_ID,
P_SCAR_REGISTRADOPOR,
SYSDATE,
P_SCAR_PROCESOAUDITORIA,
'D'
FROM TRAMITE.SOLICITUDCARGAARCHIVO WHERE SCAR_ID = P_SCAR_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDCARGAARCHIVO WHERE SCAR_ID = P_SCAR_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.solicitudcierreviaarchivo (
    scva_id                NUMBER(30) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    scva_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    scva_fechacambio       DATE NOT NULL,
    scva_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudcierreviaarchivo IS
    'Almacena los archivos anexos a las solicitudes de Cierre Parcial de Vias Para Eventos Deportivos';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.scva_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.arch_id IS
    'ALMACENA EL IDENTIFICADOR DEL ARCHIVO';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA SOLICITUD';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.scva_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.scva_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudcierreviaarchivo.scva_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.scva_pk ON
    tramite.solicitudcierreviaarchivo (
        scva_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudcierreviaarchivo
    ADD CONSTRAINT scva_pk PRIMARY KEY ( scva_id )
        USING INDEX tramite.scva_pk;

CREATE TABLE tramite.aud_solicitudcierreviaarchivo (
    scva_id                NUMBER(30),
    arch_id                NUMBER(30),
    soli_id                NUMBER(30),
    scva_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    scva_fechacambio       DATE NOT NULL,
    scva_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    scva_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLICIERREVIAAR (
P_SCVA_ID IN SOLICITUDCIERREVIAARCHIVO.SCVA_ID%TYPE,
P_SCVA_REGISTRADOPOR IN SOLICITUDCIERREVIAARCHIVO.SCVA_REGISTRADOPOR%TYPE,
P_SCVA_PROCESOAUDITORIA IN SOLICITUDCIERREVIAARCHIVO.SCVA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDCIERREVIAARCHIVO(
SCVA_ID,
ARCH_ID,
SOLI_ID,
SCVA_REGISTRADOPOR,
SCVA_FECHACAMBIO,
SCVA_PROCESOAUDITORIA,
SCVA_OPERACION
)
SELECT
SCVA_ID,
ARCH_ID,
SOLI_ID,
P_SCVA_REGISTRADOPOR,
SYSDATE,
P_SCVA_PROCESOAUDITORIA,
'D'
FROM TRAMITE.SOLICITUDCIERREVIAARCHIVO WHERE SCVA_ID = P_SCVA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDCIERREVIAARCHIVO WHERE SCVA_ID = P_SCVA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_solicitud (
    soli_id                NUMBER(30),
    tram_id                NUMBER(30),
    soli_registradopor     VARCHAR2(30 BYTE),
    soli_fechacambio       DATE,
    soli_activarimpresion  VARCHAR2(1 BYTE),
    soli_activo            VARCHAR2(1 BYTE),
    soli_procesoauditoria  VARCHAR2(300 BYTE),
    soli_fecha             DATE,
    pers_id                NUMBER(30),
    soli_operacion         VARCHAR2(1 BYTE) NOT NULL,
    esso_id                NUMBER(30) NOT NULL,
    soli_radicado          VARCHAR2(30 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 327680 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLICITUD (
P_SOLI_ID IN SOLICITUD.SOLI_ID%TYPE,
P_SOLI_REGISTRADOPOR IN SOLICITUD.SOLI_REGISTRADOPOR%TYPE,
P_SOLI_PROCESOAUDITORIA IN SOLICITUD.SOLI_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUD(
ESSO_ID,
SOLI_ID,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_RADICADO,
SOLI_OPERACION
)
SELECT
ESSO_ID,
SOLI_ID,
TRAM_ID,
P_SOLI_REGISTRADOPOR,
SYSDATE,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
P_SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_RADICADO,
'D'
FROM TRAMITE.SOLICITUD WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUD WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_solicitudcarga (
    soli_id                NUMBER(30),
    camo_id                NUMBER(30),
    soca_fechaorigen       DATE,
    soca_fechadestino      DATE,
    soca_diasmovilizacion  VARCHAR2(10 BYTE),
    soca_numeroevasion     VARCHAR2(50 BYTE),
    soca_funcionario       VARCHAR2(100 BYTE),
    soca_registradopor     VARCHAR2(30 BYTE),
    soca_fechacambio       DATE,
    soca_procesoauditoria  VARCHAR2(300 BYTE),
    pers_id                NUMBER(30),
    vehi_id                NUMBER(30),
    soca_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLICITUDCARGA (
P_SOLI_ID IN SOLICITUDCARGA.SOLI_ID%TYPE,
P_SOCA_REGISTRADOPOR IN SOLICITUDCARGA.SOCA_REGISTRADOPOR%TYPE,
P_SOCA_PROCESOAUDITORIA IN SOLICITUDCARGA.SOCA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDCARGA(
SOLI_ID,
CAMO_ID,
SOCA_FECHAORIGEN,
SOCA_FECHADESTINO,
SOCA_DIASMOVILIZACION,
SOCA_NUMEROEVASION,
SOCA_FUNCIONARIO,
SOCA_REGISTRADOPOR,
SOCA_FECHACAMBIO,
SOCA_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
SOCA_OPERACION
)
SELECT
SOLI_ID,
CAMO_ID,
SOCA_FECHAORIGEN,
SOCA_FECHADESTINO,
SOCA_DIASMOVILIZACION,
SOCA_NUMEROEVASION,
SOCA_FUNCIONARIO,
P_SOCA_REGISTRADOPOR,
SYSDATE,
P_SOCA_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
'D'
FROM TRAMITE.SOLICITUDCARGA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDCARGA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.solicitudpazysalvo (
    soli_id                NUMBER(30) NOT NULL,
    sops_formaentrega      VARCHAR2(1 BYTE),
    sops_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    sops_fechacambio       DATE NOT NULL,
    sops_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudpazysalvo IS
    'Almacena las solicitudes de tramites de Certificado Paz y Salvo Evasion de Peaje';

COMMENT ON COLUMN tramite.solicitudpazysalvo.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudpazysalvo.sops_formaentrega IS
    'ALMACENA LA FORMA DE ENTREGA DE LA SOLICITUD, C=CORREO ELECTRONICO Y O=OFICINA';

COMMENT ON COLUMN tramite.solicitudpazysalvo.sops_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudpazysalvo.sops_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudpazysalvo.sops_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_sops ON
    tramite.solicitudpazysalvo (
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpazysalvo
    ADD CONSTRAINT pk_sops PRIMARY KEY ( soli_id )
        USING INDEX tramite.pk_sops;

CREATE TABLE tramite.aud_solicitudpazysalvo (
    soli_id                NUMBER(30),
    sops_formaentrega      VARCHAR2(1 BYTE),
    sops_registradopor     VARCHAR2(30 BYTE),
    sops_fechacambio       DATE,
    sops_procesoauditoria  VARCHAR2(300 BYTE),
    sops_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLPAZYSALVO (
P_SOLI_ID IN SOLICITUDPAZYSALVO.SOLI_ID%TYPE,
P_SOPS_REGISTRADOPOR IN SOLICITUDPAZYSALVO.SOPS_REGISTRADOPOR%TYPE,
P_SOPS_PROCESOAUDITORIA IN SOLICITUDPAZYSALVO.SOPS_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDPAZYSALVO(
SOLI_ID,
SOPS_FORMAENTREGA,
SOPS_REGISTRADOPOR,
SOPS_FECHACAMBIO,
SOPS_PROCESOAUDITORIA,
SOPS_OPERACION
)
SELECT
SOLI_ID,
SOPS_FORMAENTREGA,
P_SOPS_REGISTRADOPOR,
SYSDATE,
P_SOPS_PROCESOAUDITORIA,
'D'
FROM TRAMITE.SOLICITUDPAZYSALVO WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDPAZYSALVO WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.solipazysalvoarchivo (
    spsa_id                NUMBER(30) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    spsa_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    spsa_fechacambio       DATE NOT NULL,
    spsa_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    veps_id                NUMBER(30) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solipazysalvoarchivo IS
    'Almacena los archivos de las solicitudes de Certificado Paz y Salvo Evasion de Peaje';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.spsa_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.arch_id IS
    'ALMACENA EL IDENTIFICADOR DEL ARCHIVO';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.spsa_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.spsa_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.spsa_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solipazysalvoarchivo.veps_id IS
    'ALMACENA EL IDENTIFICADOR DE VEHICULO PAZ Y SALVO';

CREATE UNIQUE INDEX tramite.pk_spsa ON
    tramite.solipazysalvoarchivo (
        spsa_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solipazysalvoarchivo
    ADD CONSTRAINT pk_spsa PRIMARY KEY ( spsa_id )
        USING INDEX tramite.pk_spsa;

CREATE TABLE tramite.aud_solipazysalvoarchivo (
    spsa_id                NUMBER(30),
    arch_id                NUMBER(30),
    spsa_registradopor     VARCHAR2(30 BYTE),
    spsa_fechacambio       DATE,
    spsa_procesoauditoria  VARCHAR2(300 BYTE),
    veps_id                NUMBER(30),
    spsa_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLPAZYSALVOARC (
P_SPSA_ID IN SOLIPAZYSALVOARCHIVO.SPSA_ID%TYPE,
P_SPSA_REGISTRADOPOR IN SOLIPAZYSALVOARCHIVO.SPSA_REGISTRADOPOR%TYPE,
P_SPSA_PROCESOAUDITORIA IN SOLIPAZYSALVOARCHIVO.SPSA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLIPAZYSALVOARCHIVO(
SPSA_ID,
ARCH_ID,
SPSA_REGISTRADOPOR,
SPSA_FECHACAMBIO,
SPSA_PROCESOAUDITORIA,
VEPS_ID,
SPSA_OPERACION
)
SELECT
SPSA_ID,
ARCH_ID,
P_SPSA_REGISTRADOPOR,
SYSDATE,
P_SPSA_PROCESOAUDITORIA,
VEPS_ID,
'D'
FROM TRAMITE.SOLIPAZYSALVOARCHIVO WHERE SPSA_ID = P_SPSA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLIPAZYSALVOARCHIVO WHERE SPSA_ID = P_SPSA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_solicitudzonaarchivo (
    soza_id                NUMBER(30),
    arch_id                NUMBER(30),
    soli_id                NUMBER(30),
    soza_registradopor     VARCHAR2(30 BYTE),
    soza_fechacambio       DATE,
    soza_procesoauditoria  VARCHAR2(300 BYTE),
    soza_tipo              VARCHAR2(1 BYTE),
    soza_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLZONAARCHIVO (
P_SOZA_ID IN SOLICITUDZONAARCHIVO.SOZA_ID%TYPE,
P_SOZA_REGISTRADOPOR IN SOLICITUDZONAARCHIVO.SOZA_REGISTRADOPOR%TYPE,
P_SOZA_PROCESOAUDITORIA IN SOLICITUDZONAARCHIVO.SOZA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDZONAARCHIVO(
SOZA_ID,
ARCH_ID,
SOLI_ID,
SOZA_REGISTRADOPOR,
SOZA_FECHACAMBIO,
SOZA_PROCESOAUDITORIA,
SOZA_TIPO,
SOZA_OPERACION
)
SELECT
SOZA_ID,
ARCH_ID,
SOLI_ID,
P_SOZA_REGISTRADOPOR,
SYSDATE,
P_SOZA_PROCESOAUDITORIA,
SOZA_TIPO,
'D'
FROM TRAMITE.SOLICITUDZONAARCHIVO WHERE SOZA_ID = P_SOZA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDZONAARCHIVO WHERE SOZA_ID = P_SOZA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.solicitudzonacarretera (
    soli_id                NUMBER(30) NOT NULL,
    sozc_margen            VARCHAR2(100 BYTE) NOT NULL,
    sozc_crucevia          VARCHAR2(100 BYTE) NOT NULL,
    sozc_fechainicio       DATE NOT NULL,
    sozc_fechafin          DATE NOT NULL,
    sozc_cronograma        VARCHAR2(4000 BYTE) NOT NULL,
    sozc_descripcion       VARCHAR2(4000 BYTE),
    sozc_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    sozc_fechacambio       DATE NOT NULL,
    sozc_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    sozc_duracion          NUMBER(30),
    szct_id                NUMBER(*, 0),
    sozc_infraestructura   VARCHAR2(50 BYTE),
    szct_tipoentidad       VARCHAR2(50 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudzonacarretera IS
    'Almacena las solicitudes de tramites de Uso Zona de Carretera';

COMMENT ON COLUMN tramite.solicitudzonacarretera.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_margen IS
    'ALMACENA LA MARGEN';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_crucevia IS
    'ALMACENA EL CRUCE DE VIA';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_fechainicio IS
    'ALMACENA LA FECHA INICIO';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_fechafin IS
    'ALMACENA LA FECHA FIN';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_cronograma IS
    'ALMACENA EL CRONOGRAMA';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_descripcion IS
    'ALMACENA LA DESCRIPCION';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudzonacarretera.sozc_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_sozc ON
    tramite.solicitudzonacarretera (
        soli_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudzonacarretera
    ADD CONSTRAINT pk_sozc PRIMARY KEY ( soli_id )
        USING INDEX tramite.pk_sozc;

CREATE TABLE tramite.aud_solicitudzonacarretera (
    soli_id                NUMBER(30),
    sozc_puntoinicial      VARCHAR2(100 BYTE),
    sozc_puntofinal        VARCHAR2(100 BYTE),
    sozc_margen            VARCHAR2(100 BYTE),
    sozc_crucevia          VARCHAR2(100 BYTE),
    sozc_fechainicio       DATE,
    sozc_fechafin          DATE,
    sozc_cronograma        VARCHAR2(4000 BYTE),
    sozc_descripcion       VARCHAR2(4000 BYTE),
    sozc_registradopor     VARCHAR2(30 BYTE),
    sozc_fechacambio       DATE,
    sozc_procesoauditoria  VARCHAR2(300 BYTE),
    sozc_operacion         VARCHAR2(1 BYTE) NOT NULL,
    sozc_duracion          NUMBER(30)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_SOLZONACARR (
P_SOLI_ID IN SOLICITUDZONACARRETERA.SOLI_ID%TYPE,
P_SOZC_REGISTRADOPOR IN SOLICITUDZONACARRETERA.SOZC_REGISTRADOPOR%TYPE,
P_SOZC_PROCESOAUDITORIA IN SOLICITUDZONACARRETERA.SOZC_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_SOLICITUDZONACARRETERA(
SOLI_ID,
SOZC_PUNTOINICIAL,
SOZC_PUNTOFINAL,
SOZC_MARGEN,
SOZC_CRUCEVIA,
SOZC_FECHAINICIO,
SOZC_FECHAFIN,
SOZC_CRONOGRAMA,
SOZC_DESCRIPCION,
SOZC_REGISTRADOPOR,
SOZC_FECHACAMBIO,
SOZC_PROCESOAUDITORIA,
SOZC_DURACION,
SOZC_OPERACION
)
SELECT
SOLI_ID,
SOZC_PUNTOINICIAL,
SOZC_PUNTOFINAL,
SOZC_MARGEN,
SOZC_CRUCEVIA,
SOZC_FECHAINICIO,
SOZC_FECHAFIN,
SOZC_CRONOGRAMA,
SOZC_DESCRIPCION,
P_SOZC_REGISTRADOPOR,
SYSDATE,
P_SOZC_PROCESOAUDITORIA,
SOZC_DURACION,
'D'
FROM TRAMITE.SOLICITUDZONACARRETERA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.SOLICITUDZONACARRETERA WHERE SOLI_ID = P_SOLI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.tipo (
    tipo_id                NUMBER(30) NOT NULL,
    tipo_descripcion       VARCHAR2(100 BYTE) NOT NULL,
    tipo_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    tipo_fechacambio       DATE NOT NULL,
    tipo_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.tipo IS
    'Almacena los tipos de clientes que utilizan el sistema (TABLA NO GESTIONABLE)';

COMMENT ON COLUMN tramite.tipo.tipo_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.tipo.tipo_descripcion IS
    'ALMACENA EL NOMBRE DEL TIPO USUARIO';

COMMENT ON COLUMN tramite.tipo.tipo_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tipo.tipo_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tipo.tipo_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_tipo_tipo_descrip ON
    tramite.tipo (
        tipo_descripcion
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_tipo ON
    tramite.tipo (
        tipo_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.tipo TO interventor;

ALTER TABLE tramite.tipo
    ADD CONSTRAINT pk_tipo PRIMARY KEY ( tipo_id )
        USING INDEX tramite.pk_tipo;

CREATE TABLE tramite.aud_tipo (
    tipo_id                NUMBER(30),
    tipo_descripcion       VARCHAR2(100 BYTE),
    tipo_registradopor     VARCHAR2(30 BYTE),
    tipo_fechacambio       DATE,
    tipo_procesoauditoria  VARCHAR2(300 BYTE),
    tipo_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TIPO (
P_TIPO_ID IN TIPO.TIPO_ID%TYPE,
P_TIPO_REGISTRADOPOR IN TIPO.TIPO_REGISTRADOPOR%TYPE,
P_TIPO_PROCESOAUDITORIA IN TIPO.TIPO_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TIPO(
TIPO_ID,
TIPO_DESCRIPCION,
TIPO_REGISTRADOPOR,
TIPO_FECHACAMBIO,
TIPO_PROCESOAUDITORIA,
TIPO_OPERACION
)
SELECT
TIPO_ID,
TIPO_DESCRIPCION,
P_TIPO_REGISTRADOPOR,
SYSDATE,
P_TIPO_PROCESOAUDITORIA,
'D'
FROM TRAMITE.TIPO WHERE TIPO_ID = P_TIPO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TIPO WHERE TIPO_ID = P_TIPO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.tipocarga (
    tica_id                NUMBER(30) NOT NULL,
    tica_nombre            VARCHAR2(500 BYTE) NOT NULL,
    tica_descripcion       VARCHAR2(4000 BYTE),
    tica_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    tica_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    tica_fechacambio       DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.tipocarga IS
    'Almacena los tipos de carga que se pueden indicar en una solicitud de carga extra-dimensionada';

COMMENT ON COLUMN tramite.tipocarga.tica_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.tipocarga.tica_nombre IS
    'ALMACENA EL NOMBRE DEL TIPO DE CARGA';

COMMENT ON COLUMN tramite.tipocarga.tica_descripcion IS
    'ALMACENA LA DESCRIPCION DEL TIPO DE CARGA';

COMMENT ON COLUMN tramite.tipocarga.tica_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tipocarga.tica_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tipocarga.tica_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_tica_tica_nombre ON
    tramite.tipocarga (
        tica_nombre
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.tica_pk ON
    tramite.tipocarga (
        tica_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tipocarga
    ADD CONSTRAINT tica_pk PRIMARY KEY ( tica_id )
        USING INDEX tramite.tica_pk;

CREATE TABLE tramite.aud_tipocarga (
    tica_id                NUMBER(30),
    tica_nombre            VARCHAR2(500 BYTE),
    tica_descripcion       VARCHAR2(4000 BYTE),
    tica_procesoauditoria  VARCHAR2(300 BYTE),
    tica_registradopor     VARCHAR2(30 BYTE),
    tica_fechacambio       DATE,
    tica_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TIPOCARGA (
P_TICA_ID IN TIPOCARGA.TICA_ID%TYPE,
P_TICA_REGISTRADOPOR IN TIPOCARGA.TICA_REGISTRADOPOR%TYPE,
P_TICA_PROCESOAUDITORIA IN TIPOCARGA.TICA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TIPOCARGA(
TICA_ID,
TICA_NOMBRE,
TICA_DESCRIPCION,
TICA_PROCESOAUDITORIA,
TICA_REGISTRADOPOR,
TICA_FECHACAMBIO,
TICA_OPERACION
)
SELECT
TICA_ID,
TICA_NOMBRE,
TICA_DESCRIPCION,
P_TICA_PROCESOAUDITORIA,
P_TICA_REGISTRADOPOR,
SYSDATE,
'D'
FROM TRAMITE.TIPOCARGA WHERE TICA_ID = P_TICA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TIPOCARGA WHERE TICA_ID = P_TICA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.tipodocumento (
    tido_id                NUMBER(30) NOT NULL,
    tido_descripcion       VARCHAR2(30 BYTE) NOT NULL,
    tido_tipopersona       VARCHAR2(1 BYTE) NOT NULL,
    tido_abreviatura       VARCHAR2(30 BYTE) NOT NULL,
    tido_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    tido_fechacambio       DATE NOT NULL,
    tido_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

ALTER TABLE tramite.tipodocumento
    ADD CONSTRAINT ck_tido_persona CHECK ( tido_tipopersona IN ( 'J', 'N' ) );

COMMENT ON TABLE tramite.tipodocumento IS
    'Almacena los tipos de documentos de identificacion';

COMMENT ON COLUMN tramite.tipodocumento.tido_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.tipodocumento.tido_descripcion IS
    'ALMACENA LA DESCRIPCION DEL TIPO DE DOCUMENTO';

COMMENT ON COLUMN tramite.tipodocumento.tido_tipopersona IS
    'ALMACENA EL TIPO DE PERSONA DEL DOCUMENTO. N: NATURAL Y J:JURIDICA';

COMMENT ON COLUMN tramite.tipodocumento.tido_abreviatura IS
    'ALMACENA LA ABREVIATURA DEL TIPO DOCUMENTO';

COMMENT ON COLUMN tramite.tipodocumento.tido_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tipodocumento.tido_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tipodocumento.tido_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_tido_tido_descrip ON
    tramite.tipodocumento (
        tido_descripcion
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_tido ON
    tramite.tipodocumento (
        tido_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tipodocumento
    ADD CONSTRAINT pk_tido PRIMARY KEY ( tido_id )
        USING INDEX tramite.pk_tido;

CREATE TABLE tramite.aud_tipodocumento (
    tido_id                NUMBER(30),
    tido_descripcion       VARCHAR2(30 BYTE),
    tido_tipopersona       VARCHAR2(1 BYTE),
    tido_abreviatura       VARCHAR2(30 BYTE),
    tido_registradopor     VARCHAR2(30 BYTE),
    tido_fechacambio       DATE,
    tido_procesoauditoria  VARCHAR2(300 BYTE),
    tido_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TIPODOCUMENTO (
P_TIDO_ID IN TIPODOCUMENTO.TIDO_ID%TYPE,
P_TIDO_REGISTRADOPOR IN TIPODOCUMENTO.TIDO_REGISTRADOPOR%TYPE,
P_TIDO_PROCESOAUDITORIA IN TIPODOCUMENTO.TIDO_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TIPODOCUMENTO(
TIDO_ID,
TIDO_DESCRIPCION,
TIDO_TIPOPERSONA,
TIDO_ABREVIATURA,
TIDO_REGISTRADOPOR,
TIDO_FECHACAMBIO,
TIDO_PROCESOAUDITORIA,
TIDO_OPERACION
)
SELECT
TIDO_ID,
TIDO_DESCRIPCION,
TIDO_TIPOPERSONA,
TIDO_ABREVIATURA,
P_TIDO_REGISTRADOPOR,
SYSDATE,
P_TIDO_PROCESOAUDITORIA,
'D'
FROM TRAMITE.TIPODOCUMENTO WHERE TIDO_ID = P_TIDO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TIPODOCUMENTO WHERE TIDO_ID = P_TIDO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.tipoestadosolicitud (
    esso_id                NUMBER(30) NOT NULL,
    tipo_id                NUMBER(30) NOT NULL,
    ties_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    ties_fechacambio       DATE NOT NULL,
    ties_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.tipoestadosolicitud IS
    'Almacena los estados a los cuales tienen acceso los tipos de clientes';

COMMENT ON COLUMN tramite.tipoestadosolicitud.esso_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA ESTADO SOLICITUD';

COMMENT ON COLUMN tramite.tipoestadosolicitud.tipo_id IS
    'ALMACENA EL IDENTIFICADOR DEL TIPO';

COMMENT ON COLUMN tramite.tipoestadosolicitud.ties_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tipoestadosolicitud.ties_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tipoestadosolicitud.ties_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_ties ON
    tramite.tipoestadosolicitud (
        esso_id
    ASC,
        tipo_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tipoestadosolicitud
    ADD CONSTRAINT pk_ties PRIMARY KEY ( esso_id,
                                         tipo_id )
        USING INDEX tramite.pk_ties;

CREATE TABLE tramite.aud_tipoestadosolicitud (
    esso_id                NUMBER(30),
    tipo_id                NUMBER(30),
    ties_registradopor     VARCHAR2(30 BYTE),
    ties_fechacambio       DATE,
    ties_procesoauditoria  VARCHAR2(300 BYTE),
    ties_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TIPOESTADOSOL (
P_ESSO_ID IN TIPOESTADOSOLICITUD.ESSO_ID%TYPE,
P_TIPO_ID IN TIPOESTADOSOLICITUD.TIPO_ID%TYPE,
P_TIES_REGISTRADOPOR IN TIPOESTADOSOLICITUD.TIES_REGISTRADOPOR%TYPE,
P_TIES_PROCESOAUDITORIA IN TIPOESTADOSOLICITUD.TIES_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TIPOESTADOSOLICITUD(
ESSO_ID,
TIPO_ID,
TIES_REGISTRADOPOR,
TIES_FECHACAMBIO,
TIES_PROCESOAUDITORIA,
TIES_OPERACION
)
SELECT
ESSO_ID,
TIPO_ID,
P_TIES_REGISTRADOPOR,
SYSDATE,
P_TIES_PROCESOAUDITORIA,
'D'
FROM TRAMITE.TIPOESTADOSOLICITUD WHERE ESSO_ID = P_ESSO_ID AND
TIPO_ID = P_TIPO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TIPOESTADOSOLICITUD WHERE ESSO_ID = P_ESSO_ID AND
TIPO_ID = P_TIPO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.tramite (
    tram_id                NUMBER(30) NOT NULL,
    tram_nombre            VARCHAR2(200 BYTE) NOT NULL,
    tram_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    tram_fechacambio       DATE NOT NULL,
    tram_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.tramite IS
    'Almacena los tipos de tramites manejados en el sistema (TABLA NO GESTIONABLE)';

COMMENT ON COLUMN tramite.tramite.tram_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.tramite.tram_nombre IS
    'ALMACENA EL NOMBRE DEL TRAMITE';

COMMENT ON COLUMN tramite.tramite.tram_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.tramite.tram_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.tramite.tram_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.i_tramite_tram_tram_nombre ON
    tramite.tramite (
        tram_nombre
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.pk_tram ON
    tramite.tramite (
        tram_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tramite
    ADD CONSTRAINT pk_tram PRIMARY KEY ( tram_id )
        USING INDEX tramite.pk_tram;

CREATE TABLE tramite.aud_tramite (
    tram_id                NUMBER(30),
    tram_nombre            VARCHAR2(200 BYTE),
    tram_registradopor     VARCHAR2(30 BYTE),
    tram_fechacambio       DATE,
    tram_procesoauditoria  VARCHAR2(300 BYTE),
    tram_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TRAMITE (
P_TRAM_ID IN TRAMITE.TRAM_ID%TYPE,
P_TRAM_REGISTRADOPOR IN TRAMITE.TRAM_REGISTRADOPOR%TYPE,
P_TRAM_PROCESOAUDITORIA IN TRAMITE.TRAM_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TRAMITE(
TRAM_ID,
TRAM_NOMBRE,
TRAM_REGISTRADOPOR,
TRAM_FECHACAMBIO,
TRAM_PROCESOAUDITORIA,
TRAM_OPERACION
)
SELECT
TRAM_ID,
TRAM_NOMBRE,
P_TRAM_REGISTRADOPOR,
SYSDATE,
P_TRAM_PROCESOAUDITORIA,
'D'
FROM TRAMITE.TRAMITE WHERE TRAM_ID = P_TRAM_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TRAMITE WHERE TRAM_ID = P_TRAM_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.aud_tramiteestadosolicitud (
    tram_id                NUMBER(30),
    esso_id                NUMBER(30),
    tres_registradopor     VARCHAR2(30 BYTE),
    tres_fechacambio       DATE,
    tres_procesoauditoria  VARCHAR2(300 BYTE),
    tres_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_TRAMITEESTADOSOL (
P_TRAM_ID IN TRAMITEESTADOSOLICITUD.TRAM_ID%TYPE,
P_ESSO_ID IN TRAMITEESTADOSOLICITUD.ESSO_ID%TYPE,
P_TRES_REGISTRADOPOR IN TRAMITEESTADOSOLICITUD.TRES_REGISTRADOPOR%TYPE,
P_TRES_PROCESOAUDITORIA IN TRAMITEESTADOSOLICITUD.TRES_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_TRAMITEESTADOSOLICITUD(
TRAM_ID,
ESSO_ID,
TRES_REGISTRADOPOR,
TRES_FECHACAMBIO,
TRES_PROCESOAUDITORIA,
TRES_OPERACION
)
SELECT
TRAM_ID,
ESSO_ID,
P_TRES_REGISTRADOPOR,
SYSDATE,
P_TRES_PROCESOAUDITORIA,
'D'
FROM TRAMITE.TRAMITEESTADOSOLICITUD WHERE TRAM_ID = P_TRAM_ID AND
ESSO_ID = P_ESSO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.TRAMITEESTADOSOLICITUD WHERE TRAM_ID = P_TRAM_ID AND
ESSO_ID = P_ESSO_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.usuario (
    usua_id                NUMBER(30) NOT NULL,
    pers_id                NUMBER(30) NOT NULL,
    usua_documento         VARCHAR2(100 BYTE) NOT NULL,
    usua_contrasena        VARCHAR2(100 BYTE) NOT NULL,
    usua_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    usua_fechacambio       DATE NOT NULL,
    usua_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    tido_id                NUMBER(30) NOT NULL,
    usua_estado            VARCHAR2(1 BYTE) DEFAULT 'A' NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.usuario IS
    'Almacena los usuarios del sistema';

COMMENT ON COLUMN tramite.usuario.usua_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.usuario.pers_id IS
    'ALMACENA EL IDENTIFICADOR DE LA PERSONA';

COMMENT ON COLUMN tramite.usuario.usua_documento IS
    'ALMACENA EL NOMBRE DEL USUARIO';

COMMENT ON COLUMN tramite.usuario.usua_contrasena IS
    'ALMACENA LA CONTRASE?A DEL USUARIO';

COMMENT ON COLUMN tramite.usuario.usua_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.usuario.usua_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.usuario.usua_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.usuario.tido_id IS
    'ALMACENA EL IDENTIFICADOR DEL TIPO DE DOCUMENTO';

COMMENT ON COLUMN tramite.usuario.usua_estado IS
    'ALMACENA EL ESTADO DEL USUARIO';

CREATE UNIQUE INDEX tramite.pk_usua ON
    tramite.usuario (
        usua_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.usuario TO tramite_consulta;

GRANT SELECT ON tramite.usuario TO interventor;

ALTER TABLE tramite.usuario
    ADD CONSTRAINT pk_usua PRIMARY KEY ( usua_id )
        USING INDEX tramite.pk_usua;

CREATE TABLE tramite.aud_usuario (
    usua_id                NUMBER(30),
    pers_id                NUMBER(30),
    usua_documento         VARCHAR2(100 BYTE),
    usua_contrasena        VARCHAR2(100 BYTE),
    usua_registradopor     VARCHAR2(30 BYTE),
    usua_fechacambio       DATE,
    usua_procesoauditoria  VARCHAR2(300 BYTE),
    tido_id                NUMBER(30),
    usua_operacion         VARCHAR2(1 BYTE) NOT NULL,
    usua_estado            VARCHAR2(1 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_USUARIO (
P_USUA_ID IN USUARIO.USUA_ID%TYPE,
P_USUA_REGISTRADOPOR IN USUARIO.USUA_REGISTRADOPOR%TYPE,
P_USUA_PROCESOAUDITORIA IN USUARIO.USUA_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_USUARIO(
USUA_ID,
PERS_ID,
USUA_DOCUMENTO,
USUA_CONTRASENA,
USUA_REGISTRADOPOR,
USUA_FECHACAMBIO,
USUA_PROCESOAUDITORIA,
TIDO_ID,
USUA_ESTADO,
USUA_OPERACION
)
SELECT
USUA_ID,
PERS_ID,
USUA_DOCUMENTO,
USUA_CONTRASENA,
P_USUA_REGISTRADOPOR,
SYSDATE,
P_USUA_PROCESOAUDITORIA,
TIDO_ID,
USUA_ESTADO,
'D'
FROM TRAMITE.USUARIO WHERE USUA_ID = P_USUA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.USUARIO WHERE USUA_ID = P_USUA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.usuariotipo (
    tipo_id                NUMBER(30) NOT NULL,
    usua_id                NUMBER(30) NOT NULL,
    usti_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    usti_fechacambio       DATE NOT NULL,
    usti_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    usti_estado            VARCHAR2(10 BYTE) NOT NULL,
    usti_ultimoingreso     DATE
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.usuariotipo IS
    'Almacena los tipos de usuario que tienen asignados los usuarios del sistema';

COMMENT ON COLUMN tramite.usuariotipo.tipo_id IS
    'ALMACENA EL IDENTIFICADOR DEL TIPO USUARIO';

COMMENT ON COLUMN tramite.usuariotipo.usua_id IS
    'ALMACENA EL IDENTIFICADOR DEL USUARIO';

COMMENT ON COLUMN tramite.usuariotipo.usti_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.usuariotipo.usti_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.usuariotipo.usti_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.usuariotipo.usti_estado IS
    'ALMACENA EL ESTADO DEL USUARIO EN UN TIPO A=ACTIVO Y I=INACTIVO';

COMMENT ON COLUMN tramite.usuariotipo.usti_ultimoingreso IS
    'ALMACENA LA FECHA DEL ULTIMO INGRESO';

CREATE UNIQUE INDEX tramite.pk_usti ON
    tramite.usuariotipo (
        tipo_id
    ASC,
        usua_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.usuariotipo TO interventor;

ALTER TABLE tramite.usuariotipo
    ADD CONSTRAINT pk_usti PRIMARY KEY ( tipo_id,
                                         usua_id )
        USING INDEX tramite.pk_usti;

CREATE TABLE tramite.aud_usuariotipo (
    tipo_id                NUMBER(30),
    usua_id                NUMBER(30),
    usti_registradopor     VARCHAR2(30 BYTE),
    usti_fechacambio       DATE,
    usti_procesoauditoria  VARCHAR2(300 BYTE),
    usti_estado            VARCHAR2(10 BYTE),
    usti_ultimoingreso     DATE,
    usti_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 2097152 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_USUARIOTIPO (
P_TIPO_ID IN USUARIOTIPO.TIPO_ID%TYPE,
P_USUA_ID IN USUARIOTIPO.USUA_ID%TYPE,
P_USTI_REGISTRADOPOR IN USUARIOTIPO.USTI_REGISTRADOPOR%TYPE,
P_USTI_PROCESOAUDITORIA IN USUARIOTIPO.USTI_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_USUARIOTIPO(
TIPO_ID,
USUA_ID,
USTI_REGISTRADOPOR,
USTI_FECHACAMBIO,
USTI_PROCESOAUDITORIA,
USTI_ESTADO,
USTI_ULTIMOINGRESO,
USTI_OPERACION
)
SELECT
TIPO_ID,
USUA_ID,
P_USTI_REGISTRADOPOR,
SYSDATE,
P_USTI_PROCESOAUDITORIA,
USTI_ESTADO,
USTI_ULTIMOINGRESO,
'D'
FROM TRAMITE.USUARIOTIPO WHERE TIPO_ID = P_TIPO_ID AND
USUA_ID = P_USUA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.USUARIOTIPO WHERE TIPO_ID = P_TIPO_ID AND
USUA_ID = P_USUA_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.valordiatramitecarga (
    vdtc_id                NUMBER(30) NOT NULL,
    vige_id                NUMBER(30) NOT NULL,
    vdtc_estado            VARCHAR2(1 BYTE) NOT NULL,
    vdtc_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    vdtc_fechacambio       DATE NOT NULL,
    vdtc_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    vdtc_valor             VARCHAR2(30 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.valordiatramitecarga IS
    'Almacena el valor del dia para cada a?o para los tramites de carga extra-dimensionada';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.valordiatramitecarga.vige_id IS
    'ALMACENA EL IDENTIFICADOR DE LA VIGENCIA';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_estado IS
    'ALMACENA EL ESTADO DEL VALOR DIA TRAMITE CARGA';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.valordiatramitecarga.vdtc_valor IS
    'ALMACENA EL VALOR';

CREATE UNIQUE INDEX tramite.vdtc_pk ON
    tramite.valordiatramitecarga (
        vdtc_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.valordiatramitecarga
    ADD CONSTRAINT vdtc_pk PRIMARY KEY ( vdtc_id )
        USING INDEX tramite.vdtc_pk;

CREATE TABLE tramite.aud_valordiatramitecarga (
    vdtc_id                NUMBER(30),
    vige_id                NUMBER(30),
    vdtc_estado            VARCHAR2(1 BYTE),
    vdtc_registradopor     VARCHAR2(30 BYTE),
    vdtc_fechacambio       DATE,
    vdtc_procesoauditoria  VARCHAR2(300 BYTE),
    vdtc_operacion         VARCHAR2(1 BYTE) NOT NULL,
    vdtc_valor             VARCHAR2(30 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_VALORDIATRACA (
P_VDTC_ID IN VALORDIATRAMITECARGA.VDTC_ID%TYPE,
P_VDTC_REGISTRADOPOR IN VALORDIATRAMITECARGA.VDTC_REGISTRADOPOR%TYPE,
P_VDTC_PROCESOAUDITORIA IN VALORDIATRAMITECARGA.VDTC_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_VALORDIATRAMITECARGA(
VDTC_ID,
VIGE_ID,
VDTC_ESTADO,
VDTC_REGISTRADOPOR,
VDTC_FECHACAMBIO,
VDTC_PROCESOAUDITORIA,
VDTC_VALOR,
VDTC_OPERACION
)
SELECT
VDTC_ID,
VIGE_ID,
VDTC_ESTADO,
P_VDTC_REGISTRADOPOR,
SYSDATE,
P_VDTC_PROCESOAUDITORIA,
VDTC_VALOR,
'D'
FROM TRAMITE.VALORDIATRAMITECARGA WHERE VDTC_ID = P_VDTC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.VALORDIATRAMITECARGA WHERE VDTC_ID = P_VDTC_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.vehiculo (
    vehi_id                NUMBER(30) NOT NULL,
    vehi_marca             VARCHAR2(100 BYTE) NOT NULL,
    vehi_placa             VARCHAR2(100 BYTE) NOT NULL,
    vehi_tipovehiculo      VARCHAR2(100 BYTE) NOT NULL,
    vehi_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    vehi_fechacambio       DATE NOT NULL,
    vehi_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    vehi_ejes              NUMBER(*, 0),
    vehi_llantas           NUMBER(*, 0),
    vehi_presion_inflado   NUMBER(6, 2),
    vehi_espropiedad       NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.vehiculo IS
    'Almacena los datos de los vehiculos';

COMMENT ON COLUMN tramite.vehiculo.vehi_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.vehiculo.vehi_marca IS
    'ALMACENA LA MARCA DEL VEHICULO';

COMMENT ON COLUMN tramite.vehiculo.vehi_placa IS
    'ALMACENA EL NUMERO DE LA PLACA DEL VEHICULO';

COMMENT ON COLUMN tramite.vehiculo.vehi_tipovehiculo IS
    'ALMACENA EL TIPO VEHICULO';

COMMENT ON COLUMN tramite.vehiculo.vehi_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.vehiculo.vehi_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.vehiculo.vehi_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_vehi ON
    tramite.vehiculo (
        vehi_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

GRANT SELECT ON tramite.vehiculo TO tramite_consulta;

ALTER TABLE tramite.vehiculo
    ADD CONSTRAINT pk_vehi PRIMARY KEY ( vehi_id )
        USING INDEX tramite.pk_vehi;

CREATE TABLE tramite.aud_vehiculo (
    vehi_id                NUMBER(30),
    vehi_marca             VARCHAR2(100 BYTE),
    vehi_placa             VARCHAR2(100 BYTE),
    vehi_tipovehiculo      VARCHAR2(100 BYTE),
    vehi_registradopor     VARCHAR2(30 BYTE),
    vehi_fechacambio       DATE,
    vehi_procesoauditoria  VARCHAR2(300 BYTE),
    vehi_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_VEHICULO (
P_VEHI_ID IN VEHICULO.VEHI_ID%TYPE,
P_VEHI_REGISTRADOPOR IN VEHICULO.VEHI_REGISTRADOPOR%TYPE,
P_VEHI_PROCESOAUDITORIA IN VEHICULO.VEHI_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_VEHICULO(
VEHI_ID,
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
VEHI_REGISTRADOPOR,
VEHI_FECHACAMBIO,
VEHI_PROCESOAUDITORIA,
VEHI_OPERACION
)
SELECT
VEHI_ID,
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
P_VEHI_REGISTRADOPOR,
SYSDATE,
P_VEHI_PROCESOAUDITORIA,
'D'
FROM TRAMITE.VEHICULO WHERE VEHI_ID = P_VEHI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.VEHICULO WHERE VEHI_ID = P_VEHI_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.vehiculopazysalvo (
    veps_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    veps_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    veps_fechacambio       DATE NOT NULL,
    veps_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    veps_estado            VARCHAR2(1 BYTE),
    veps_placa             VARCHAR2(100 BYTE) NOT NULL,
    veps_total             NUMBER(17) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.vehiculopazysalvo IS
    'Almacena los vehiculos incluidos en la solicitud de tramite de Certificado Paz y Salvo Evasion de Peaje';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.vehiculopazysalvo.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA SOLICITUD';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_estado IS
    'ALAMACENA EL ESTADO DE LA SOLICITUD DEL PAZ Y SALVO POR CADA CARRO, M=MULTADO Y P=PAZYSALVO';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_placa IS
    'ALMACENA LA PLACA DEL VEHICULO';

COMMENT ON COLUMN tramite.vehiculopazysalvo.veps_total IS
    'ALMACENA EL TOTAL';

CREATE UNIQUE INDEX tramite.pk_veps ON
    tramite.vehiculopazysalvo (
        veps_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.vehiculopazysalvo
    ADD CONSTRAINT pk_veps PRIMARY KEY ( veps_id )
        USING INDEX tramite.pk_veps;

CREATE TABLE tramite.aud_vehiculopazysalvo (
    veps_id                NUMBER(30),
    soli_id                NUMBER(30),
    veps_registradopor     VARCHAR2(30 BYTE),
    veps_fechacambio       DATE,
    veps_procesoauditoria  VARCHAR2(300 BYTE),
    veps_estado            VARCHAR2(1 BYTE),
    veps_placa             VARCHAR2(100 BYTE),
    veps_total             NUMBER(17),
    veps_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_VEHICULOPAZYSALVO (
P_VEPS_ID IN VEHICULOPAZYSALVO.VEPS_ID%TYPE,
P_VEPS_REGISTRADOPOR IN VEHICULOPAZYSALVO.VEPS_REGISTRADOPOR%TYPE,
P_VEPS_PROCESOAUDITORIA IN VEHICULOPAZYSALVO.VEPS_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_VEHICULOPAZYSALVO(
VEPS_ID,
SOLI_ID,
VEPS_REGISTRADOPOR,
VEPS_FECHACAMBIO,
VEPS_PROCESOAUDITORIA,
VEPS_ESTADO,
VEPS_PLACA,
VEPS_TOTAL,
VEPS_OPERACION
)
SELECT
VEPS_ID,
SOLI_ID,
P_VEPS_REGISTRADOPOR,
SYSDATE,
P_VEPS_PROCESOAUDITORIA,
VEPS_ESTADO,
VEPS_PLACA,
VEPS_TOTAL,
'D'
FROM TRAMITE.VEHICULOPAZYSALVO WHERE VEPS_ID = P_VEPS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.VEHICULOPAZYSALVO WHERE VEPS_ID = P_VEPS_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE TABLE tramite.vigencia (
    vige_id                NUMBER(30) NOT NULL,
    vige_anio              VARCHAR2(4 BYTE) NOT NULL,
    vige_estado            VARCHAR2(1 BYTE) NOT NULL,
    vige_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    vige_fechacambio       DATE NOT NULL,
    vige_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.vigencia IS
    'Almacena las vigencias o a?os';

COMMENT ON COLUMN tramite.vigencia.vige_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.vigencia.vige_anio IS
    'ALMACENA EL A?O DE VIGENCIA';

COMMENT ON COLUMN tramite.vigencia.vige_estado IS
    'ALMACENA EL ESTADO DE LA VIGENCIA A=ACTIVO E I=INACTIVO';

COMMENT ON COLUMN tramite.vigencia.vige_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.vigencia.vige_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.vigencia.vige_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_vige ON
    tramite.vigencia (
        vige_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE UNIQUE INDEX tramite.vige_anio_idx ON
    tramite.vigencia (
        vige_anio
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE INDEX tramite.vige_estado_idx ON
    tramite.vigencia (
        vige_estado
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.vigencia
    ADD CONSTRAINT pk_vige PRIMARY KEY ( vige_id )
        USING INDEX tramite.pk_vige;

CREATE TABLE tramite.aud_vigencia (
    vige_id                NUMBER(30),
    vige_anio              VARCHAR2(4 BYTE),
    vige_estado            VARCHAR2(1 BYTE),
    vige_registradopor     VARCHAR2(30 BYTE),
    vige_fechacambio       DATE,
    vige_procesoauditoria  VARCHAR2(300 BYTE),
    vige_operacion         VARCHAR2(1 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_D_VIGENCIA (
P_VIGE_ID IN VIGENCIA.VIGE_ID%TYPE,
P_VIGE_REGISTRADOPOR IN VIGENCIA.VIGE_REGISTRADOPOR%TYPE,
P_VIGE_PROCESOAUDITORIA IN VIGENCIA.VIGE_PROCESOAUDITORIA%TYPE,
P_EXITO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN
P_EXITO:=1;

INSERT INTO tramite.AUD_VIGENCIA(
VIGE_ID,
VIGE_ANIO,
VIGE_ESTADO,
VIGE_REGISTRADOPOR,
VIGE_FECHACAMBIO,
VIGE_PROCESOAUDITORIA,
VIGE_OPERACION
)
SELECT
VIGE_ID,
VIGE_ANIO,
VIGE_ESTADO,
P_VIGE_REGISTRADOPOR,
SYSDATE,
P_VIGE_PROCESOAUDITORIA,
'D'
FROM TRAMITE.VIGENCIA WHERE VIGE_ID = P_VIGE_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

DELETE FROM TRAMITE.VIGENCIA WHERE VIGE_ID = P_VIGE_ID;

IF SQL%NOTFOUND THEN
RAISE E_ERROR;
END IF;

EXCEPTION
WHEN OTHERS THEN
P_EXITO:=0;
ROLLBACK;
IF SQLCODE=-2292 THEN
RAISE;
END IF;
END ;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_ARCHIVO (
P_ARCH_EXTENSION IN ARCHIVO.ARCH_EXTENSION%TYPE,
P_ARCH_NOMBRE IN ARCHIVO.ARCH_NOMBRE%TYPE,
P_ARCH_ARCHIVO IN ARCHIVO.ARCH_ARCHIVO%TYPE,
P_ARCH_REGISTRADOPOR IN ARCHIVO.ARCH_REGISTRADOPOR%TYPE,
P_ARCH_FECHACAMBIO IN ARCHIVO.ARCH_FECHACAMBIO%TYPE,
P_ARCH_PROCESOAUDITORIA IN ARCHIVO.ARCH_PROCESOAUDITORIA%TYPE,
P_ARCH_DESCRIPCION IN ARCHIVO.ARCH_DESCRIPCION%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.ARCHIVO(
ARCH_EXTENSION,
ARCH_NOMBRE,
ARCH_ARCHIVO,
ARCH_REGISTRADOPOR,
ARCH_FECHACAMBIO,
ARCH_PROCESOAUDITORIA,
ARCH_DESCRIPCION
)
VALUES (
P_ARCH_EXTENSION,
P_ARCH_NOMBRE,
P_ARCH_ARCHIVO,
P_ARCH_REGISTRADOPOR,
P_ARCH_FECHACAMBIO,
P_ARCH_PROCESOAUDITORIA,
P_ARCH_DESCRIPCION
);

SELECT S_ARCH_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_ARCHIVO_SESSION (P_SESSION_ID VARCHAR, P_SOLICITUD_ID VARCHAR) 
as
BEGIN

insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_registradopor,arch_fechacambio,arch_procesoauditoria,arch_descripcion) 
    select  arcs_extension,arcs_nombre,arcs_archivo,'7162',arcs_fechacambio,arcs_procesoauditoria,arcs_session from archivo_session where arcs_session =  P_SESSION_ID;
commit;

insert into solicitudcargaarchivo(arch_id,soli_id,scar_registradopor,scar_fechacambio,scar_procesoauditoria) 
     select arch_id,P_SOLICITUD_ID,arch_registradopor,arch_fechacambio,arch_procesoauditoria from archivo where arch_descripcion = P_SESSION_ID;
            
DELETE FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION_ID;

commit;


  
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_ARCHIVOSES_ESP (P_SESSION_ID VARCHAR, P_RADICADO VARCHAR,P_PUBLICO INT) 
as 
salida  NUMBER;
solicitud_id VARCHAR(20);
BEGIN

select solicitud.SOLI_ID INTO solicitud_id from solicitud where solicitud.SOLI_RADICADO = P_RADICADO; 
 
insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_registradopor,arch_fechacambio,arch_procesoauditoria,arch_descripcion) 
    select  arcs_extension,arcs_nombre,arcs_archivo,'7162',arcs_fechacambio,arcs_procesoauditoria,arcs_session from archivo_session where arcs_session =  P_SESSION_ID;

commit;

insert into SOLICITUDPERMISOESPECIALARCH(arch_id,soli_id,sope_registradopor,sope_fechacambio,sope_procesoauditoria,arch_publico) 
     select arch_id,solicitud_id,arch_registradopor,arch_fechacambio,arch_procesoauditoria,P_PUBLICO from archivo where arch_descripcion = P_SESSION_ID;
            
DELETE FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION_ID;
update archivo set arch_descripcion =  '' where arch_descripcion =  P_SESSION_ID;

commit;

  
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_ARCHIVOSESTACION (P_SESSION_ID VARCHAR, P_RADICADO VARCHAR,P_PUBLICO INT) as 
salida  NUMBER;
solicitud_id VARCHAR(20);
BEGIN

select solicitud.SOLI_ID INTO solicitud_id from solicitud where solicitud.SOLI_RADICADO = P_RADICADO; 
 
insert into archivo(arch_extension,arch_nombre,arch_archivo,arch_registradopor,arch_fechacambio,arch_procesoauditoria,arch_descripcion,arch_doc) 
    select  arcs_extension,arcs_nombre,arcs_archivo,'7162',arcs_fechacambio,arcs_procesoauditoria,arcs_session, arcs_descripcion from archivo_session where arcs_session =  P_SESSION_ID;

commit;

-- Zona de declaración 
declare
-- Declaramos el cursor sobre una consulta de una supuesta tabla documentosestacion.

cursor documentosestacion is 
    select arcs_descripcion
    from archivo_session
    where arcs_session = P_SESSION_ID;

-- Fin declaración. Comenzamos el procedimento:

begin

-- Recorremos el cursor con un bucle for - loop
    for u in documentosestacion loop
        update SOLICITUDESTACIONARCH
        set arch_activo = '', arch_estado = '', ARCH_TIPO = ''
        where soli_id = solicitud_id and arch_tipo = u.arcs_descripcion;
    end loop; 
-- Fin bucle

end; 
-- Fin procedimiento

commit;


insert into SOLICITUDESTACIONARCH(arch_id,soli_id,sope_registradopor,sope_fechacambio,sope_procesoauditoria,arch_publico,ARCH_TIPO, ARCH_ACTIVO) 
     select arch_id,solicitud_id,arch_registradopor,arch_fechacambio,arch_procesoauditoria,P_PUBLICO, arch_doc, 0 from archivo where arch_descripcion = P_SESSION_ID;
            
DELETE FROM ARCHIVO_SESSION WHERE ARCHIVO_SESSION.ARCS_SESSION = P_SESSION_ID;
update archivo set arch_descripcion =  '' where arch_descripcion =  P_SESSION_ID;

commit;

  
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_BANCO (
P_BANC_NOMBRE IN BANCO.BANC_NOMBRE%TYPE,
P_BANC_REGISTRADOPOR IN BANCO.BANC_REGISTRADOPOR%TYPE,
P_BANC_FECHACAMBIO IN BANCO.BANC_FECHACAMBIO%TYPE,
P_BANC_PROCESOAUDITORIA IN BANCO.BANC_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.BANCO(
BANC_NOMBRE,
BANC_REGISTRADOPOR,
BANC_FECHACAMBIO,
BANC_PROCESOAUDITORIA
)
VALUES (
P_BANC_NOMBRE,
P_BANC_REGISTRADOPOR,
P_BANC_FECHACAMBIO,
P_BANC_PROCESOAUDITORIA
);

SELECT S_BANC_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_DEPARTAMENTO (
P_DEPA_NOMBRE IN DEPARTAMENTO.DEPA_NOMBRE%TYPE,
P_DEPA_REGISTRADOPOR IN DEPARTAMENTO.DEPA_REGISTRADOPOR%TYPE,
P_DEPA_FECHACAMBIO IN DEPARTAMENTO.DEPA_FECHACAMBIO%TYPE,
P_DEPA_PROCESOAUDITORIA IN DEPARTAMENTO.DEPA_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.DEPARTAMENTO(
DEPA_NOMBRE,
DEPA_REGISTRADOPOR,
DEPA_FECHACAMBIO,
DEPA_PROCESOAUDITORIA
)
VALUES (
P_DEPA_NOMBRE,
P_DEPA_REGISTRADOPOR,
P_DEPA_FECHACAMBIO,
P_DEPA_PROCESOAUDITORIA
);

SELECT S_DEPA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_DIANOHABILCARGA (
P_DNHC_FECHA IN DIANOHABILCARGA.DNHC_FECHA%TYPE,
P_DNHC_PROCESOAUDITORIA IN DIANOHABILCARGA.DNHC_PROCESOAUDITORIA%TYPE,
P_DNHC_REGISTRADOPOR IN DIANOHABILCARGA.DNHC_REGISTRADOPOR%TYPE,
P_DNHC_FECHACAMBIO IN DIANOHABILCARGA.DNHC_FECHACAMBIO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.DIANOHABILCARGA(
DNHC_FECHA,
DNHC_PROCESOAUDITORIA,
DNHC_REGISTRADOPOR,
DNHC_FECHACAMBIO
)
VALUES (
P_DNHC_FECHA,
P_DNHC_PROCESOAUDITORIA,
P_DNHC_REGISTRADOPOR,
P_DNHC_FECHACAMBIO
);

SELECT S_DNHC_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_ENCUESTA (
P_ENCU_RESPUESTA IN ENCUESTA.ENCU_RESPUESTA%TYPE,
P_ENCU_OBSERVACION IN ENCUESTA.ENCU_OBSERVACION%TYPE,
P_ENCU_REGISTRADOPOR IN ENCUESTA.ENCU_REGISTRADOPOR%TYPE,
P_ENCU_FECHACAMBIO IN ENCUESTA.ENCU_FECHACAMBIO%TYPE,
P_ENCU_PROCESOAUDITORIA IN ENCUESTA.ENCU_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.ENCUESTA(
ENCU_RESPUESTA,
ENCU_OBSERVACION,
ENCU_REGISTRADOPOR,
ENCU_FECHACAMBIO,
ENCU_PROCESOAUDITORIA
)
VALUES (
P_ENCU_RESPUESTA,
P_ENCU_OBSERVACION,
P_ENCU_REGISTRADOPOR,
P_ENCU_FECHACAMBIO,
P_ENCU_PROCESOAUDITORIA
);

SELECT S_ENCU_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_ESTADOSOLICITUD (
P_ESSO_DESCRIPCION IN ESTADOSOLICITUD.ESSO_DESCRIPCION%TYPE,
P_ESSO_TIPOESTADO IN ESTADOSOLICITUD.ESSO_TIPOESTADO%TYPE,
P_ESSO_REGISTRADOPOR IN ESTADOSOLICITUD.ESSO_REGISTRADOPOR%TYPE,
P_ESSO_FECHACAMBIO IN ESTADOSOLICITUD.ESSO_FECHACAMBIO%TYPE,
P_ESSO_PROCESOAUDITORIA IN ESTADOSOLICITUD.ESSO_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.ESTADOSOLICITUD(
ESSO_DESCRIPCION,
ESSO_TIPOESTADO,
ESSO_REGISTRADOPOR,
ESSO_FECHACAMBIO,
ESSO_PROCESOAUDITORIA
)
VALUES (
P_ESSO_DESCRIPCION,
P_ESSO_TIPOESTADO,
P_ESSO_REGISTRADOPOR,
P_ESSO_FECHACAMBIO,
P_ESSO_PROCESOAUDITORIA
);

SELECT S_ESSO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_MUNICIPIO (
P_DEPA_ID IN MUNICIPIO.DEPA_ID%TYPE,
P_MUNI_NOMBRE IN MUNICIPIO.MUNI_NOMBRE%TYPE,
P_MUNI_REGISTRADOPOR IN MUNICIPIO.MUNI_REGISTRADOPOR%TYPE,
P_MUNI_FECHACAMBIO IN MUNICIPIO.MUNI_FECHACAMBIO%TYPE,
P_MUNI_PROCESOAUDITORIA IN MUNICIPIO.MUNI_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.MUNICIPIO(
DEPA_ID,
MUNI_NOMBRE,
MUNI_REGISTRADOPOR,
MUNI_FECHACAMBIO,
MUNI_PROCESOAUDITORIA
)
VALUES (
P_DEPA_ID,
P_MUNI_NOMBRE,
P_MUNI_REGISTRADOPOR,
P_MUNI_FECHACAMBIO,
P_MUNI_PROCESOAUDITORIA
);

SELECT S_MUNI_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_PARAMETRIZACION (
P_PARA_REDVIAL IN PARAMETRIZACION.PARA_REDVIAL%TYPE,
P_PARA_ANCHO IN PARAMETRIZACION.PARA_ANCHO%TYPE,
P_PARA_ALTO IN PARAMETRIZACION.PARA_ALTO%TYPE,
P_PARA_LONGITUDSOBRESALIENTE IN PARAMETRIZACION.PARA_LONGITUDSOBRESALIENTE%TYPE,
P_PARA_LEYENDA IN PARAMETRIZACION.PARA_LEYENDA%TYPE,
P_PARA_URLAPLICATIVO IN PARAMETRIZACION.PARA_URLAPLICATIVO%TYPE,
P_PARA_PAGOELECTRONICO IN PARAMETRIZACION.PARA_PAGOELECTRONICO%TYPE,
P_PARA_IMPRESIONRECIBOPAG IN PARAMETRIZACION.PARA_IMPRESIONRECIBOPAG%TYPE,
P_PARA_SOLITRANSPORTECARG IN PARAMETRIZACION.PARA_SOLITRANSPORTECARG%TYPE,
P_PARA_SOLIUSOZONACARRETE IN PARAMETRIZACION.PARA_SOLIUSOZONACARRETE%TYPE,
P_PARA_SOLICIERREVIA IN PARAMETRIZACION.PARA_SOLICIERREVIA%TYPE,
P_PARA_SOLIPAZYSALVO IN PARAMETRIZACION.PARA_SOLIPAZYSALVO%TYPE,
P_PARA_REGISTRADOPOR IN PARAMETRIZACION.PARA_REGISTRADOPOR%TYPE,
P_PARA_FECHACAMBIO IN PARAMETRIZACION.PARA_FECHACAMBIO%TYPE,
P_PARA_PROCESOAUDITORIA IN PARAMETRIZACION.PARA_PROCESOAUDITORIA%TYPE,
P_PARA_CORREOREMITENTE IN PARAMETRIZACION.PARA_CORREOREMITENTE%TYPE,
P_PARA_ESFITRAMITECARGA IN PARAMETRIZACION.PARA_ESFITRAMITECARGA%TYPE,
P_PARA_PESO IN PARAMETRIZACION.PARA_PESO%TYPE,
P_PARA_CARGO IN PARAMETRIZACION.PARA_CARGO%TYPE,
P_PARA_FUNCIONARIO IN PARAMETRIZACION.PARA_FUNCIONARIO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.PARAMETRIZACION(
PARA_REDVIAL,
PARA_ANCHO,
PARA_ALTO,
PARA_LONGITUDSOBRESALIENTE,
PARA_LEYENDA,
PARA_URLAPLICATIVO,
PARA_PAGOELECTRONICO,
PARA_IMPRESIONRECIBOPAG,
PARA_SOLITRANSPORTECARG,
PARA_SOLIUSOZONACARRETE,
PARA_SOLICIERREVIA,
PARA_SOLIPAZYSALVO,
PARA_REGISTRADOPOR,
PARA_FECHACAMBIO,
PARA_PROCESOAUDITORIA,
PARA_CORREOREMITENTE,
PARA_ESFITRAMITECARGA,
PARA_PESO,
PARA_CARGO,
PARA_FUNCIONARIO
)
VALUES (
P_PARA_REDVIAL,
P_PARA_ANCHO,
P_PARA_ALTO,
P_PARA_LONGITUDSOBRESALIENTE,
P_PARA_LEYENDA,
P_PARA_URLAPLICATIVO,
P_PARA_PAGOELECTRONICO,
P_PARA_IMPRESIONRECIBOPAG,
P_PARA_SOLITRANSPORTECARG,
P_PARA_SOLIUSOZONACARRETE,
P_PARA_SOLICIERREVIA,
P_PARA_SOLIPAZYSALVO,
P_PARA_REGISTRADOPOR,
P_PARA_FECHACAMBIO,
P_PARA_PROCESOAUDITORIA,
P_PARA_CORREOREMITENTE,
P_PARA_ESFITRAMITECARGA,
P_PARA_PESO,
P_PARA_CARGO,
P_PARA_FUNCIONARIO
);

SELECT S_PARA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_PERSONA (
P_TIDO_ID IN PERSONA.TIDO_ID%TYPE,
P_MUNI_ID IN PERSONA.MUNI_ID%TYPE,
P_DEPA_ID IN PERSONA.DEPA_ID%TYPE,
P_PERS_DOCUMENTOIDENTIDAD IN PERSONA.PERS_DOCUMENTOIDENTIDAD%TYPE,
P_PERS_DIRECCION IN PERSONA.PERS_DIRECCION%TYPE,
P_PERS_TELEFONO IN PERSONA.PERS_TELEFONO%TYPE,
P_PERS_CORREOELECTRONICO IN PERSONA.PERS_CORREOELECTRONICO%TYPE,
P_PERS_FAX IN PERSONA.PERS_FAX%TYPE,
P_PERS_REGISTRADOPOR IN PERSONA.PERS_REGISTRADOPOR%TYPE,
P_PERS_FECHACAMBIO IN PERSONA.PERS_FECHACAMBIO%TYPE,
P_PERS_PROCESOAUDITORIA IN PERSONA.PERS_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.PERSONA(
TIDO_ID,
MUNI_ID,
DEPA_ID,
PERS_DOCUMENTOIDENTIDAD,
PERS_DIRECCION,
PERS_TELEFONO,
PERS_CORREOELECTRONICO,
PERS_FAX,
PERS_REGISTRADOPOR,
PERS_FECHACAMBIO,
PERS_PROCESOAUDITORIA
)
VALUES (
P_TIDO_ID,
P_MUNI_ID,
P_DEPA_ID,
P_PERS_DOCUMENTOIDENTIDAD,
P_PERS_DIRECCION,
P_PERS_TELEFONO,
P_PERS_CORREOELECTRONICO,
P_PERS_FAX,
P_PERS_REGISTRADOPOR,
P_PERS_FECHACAMBIO,
P_PERS_PROCESOAUDITORIA
);

SELECT S_PERS_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_PROGREVENTO (
P_PREV_MUNICIPIOSALIDA IN PROGRAMACIONEVENTO.PREV_MUNICIPIOSALIDA%TYPE,
P_PREV_MUNICIPIOLLEGADA IN PROGRAMACIONEVENTO.PREV_MUNICIPIOLLEGADA%TYPE,
P_PREV_FECHA IN PROGRAMACIONEVENTO.PREV_FECHA%TYPE,
P_PREV_HORASALIDA IN PROGRAMACIONEVENTO.PREV_HORASALIDA%TYPE,
P_PREV_HORALLEGADA IN PROGRAMACIONEVENTO.PREV_HORALLEGADA%TYPE,
P_PREV_LUGARSALIDA IN PROGRAMACIONEVENTO.PREV_LUGARSALIDA%TYPE,
P_PREV_LUGARLLEGADA IN PROGRAMACIONEVENTO.PREV_LUGARLLEGADA%TYPE,
P_PREV_FECHACAMBIO IN PROGRAMACIONEVENTO.PREV_FECHACAMBIO%TYPE,
P_PREV_PROCESOAUDITORIA IN PROGRAMACIONEVENTO.PREV_PROCESOAUDITORIA%TYPE,
P_PREV_REGISTRADOPOR IN PROGRAMACIONEVENTO.PREV_REGISTRADOPOR%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.PROGRAMACIONEVENTO(
PREV_MUNICIPIOSALIDA,
PREV_MUNICIPIOLLEGADA,
PREV_FECHA,
PREV_HORASALIDA,
PREV_HORALLEGADA,
PREV_LUGARSALIDA,
PREV_LUGARLLEGADA,
PREV_FECHACAMBIO,
PREV_PROCESOAUDITORIA,
PREV_REGISTRADOPOR
)
VALUES (
P_PREV_MUNICIPIOSALIDA,
P_PREV_MUNICIPIOLLEGADA,
P_PREV_FECHA,
P_PREV_HORASALIDA,
P_PREV_HORALLEGADA,
P_PREV_LUGARSALIDA,
P_PREV_LUGARLLEGADA,
P_PREV_FECHACAMBIO,
P_PREV_PROCESOAUDITORIA,
P_PREV_REGISTRADOPOR
);

SELECT S_PREV_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_REGISTRAMITE (
P_ARCH_ID IN SOLIPAZYSALVOARCHIVO.ARCH_ID%TYPE,
P_SPSA_REGISTRADOPOR IN SOLIPAZYSALVOARCHIVO.SPSA_REGISTRADOPOR%TYPE,
P_SPSA_FECHACAMBIO IN SOLIPAZYSALVOARCHIVO.SPSA_FECHACAMBIO%TYPE,
P_SPSA_PROCESOAUDITORIA IN SOLIPAZYSALVOARCHIVO.SPSA_PROCESOAUDITORIA%TYPE,
P_VEPS_ID IN SOLIPAZYSALVOARCHIVO.VEPS_ID%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLIPAZYSALVOARCHIVO(
ARCH_ID,
SPSA_REGISTRADOPOR,
SPSA_FECHACAMBIO,
SPSA_PROCESOAUDITORIA,
VEPS_ID
)
VALUES (
P_ARCH_ID,
P_SPSA_REGISTRADOPOR,
P_SPSA_FECHACAMBIO,
P_SPSA_PROCESOAUDITORIA,
P_VEPS_ID
);

SELECT S_SPSA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_REMOLQUE (
P_REMO_PLACA IN REMOLQUE.REMO_PLACA%TYPE,
P_REMO_REGISTRADOPOR IN REMOLQUE.REMO_REGISTRADOPOR%TYPE,
P_REMO_FECHACAMBIO IN REMOLQUE.REMO_FECHACAMBIO%TYPE,
P_REMO_PROCESOAUDITORIA IN REMOLQUE.REMO_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.REMOLQUE(
REMO_PLACA,
REMO_REGISTRADOPOR,
REMO_FECHACAMBIO,
REMO_PROCESOAUDITORIA
)
VALUES (
P_REMO_PLACA,
P_REMO_REGISTRADOPOR,
P_REMO_FECHACAMBIO,
P_REMO_PROCESOAUDITORIA
);

SELECT S_REMO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_REMOLQUE_EXT (
P_REMO_PLACA IN REMOLQUE.REMO_PLACA%TYPE,
P_REMO_NUMERO_EJES IN REMOLQUE.REMO_NUMERO_EJES%TYPE,
P_REMO_NUMERO_LLANTAS_EJE IN REMOLQUE.REMO_NUMERO_LLANTAS_EJE%TYPE,
P_REMO_PRESION_INFLADO_LLANTAS IN REMOLQUE.REMO_PRESION_INFLADO_LLANTAS%TYPE,
P_REMO_ESPROPIEDAD IN REMOLQUE.REMO_ESPROPIEDAD%TYPE,
P_REMO_REGISTRADOPOR IN REMOLQUE.REMO_REGISTRADOPOR%TYPE,
P_REMO_FECHACAMBIO IN REMOLQUE.REMO_FECHACAMBIO%TYPE,
P_REMO_PROCESOAUDITORIA IN REMOLQUE.REMO_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN



INSERT INTO tramite.REMOLQUE(
REMO_PLACA,
REMO_NUMERO_EJES,
REMO_NUMERO_LLANTAS_EJE,
REMO_PRESION_INFLADO_LLANTAS,
REMO_ESPROPIEDAD,
REMO_REGISTRADOPOR,
REMO_FECHACAMBIO,
REMO_PROCESOAUDITORIA
)
VALUES (
P_REMO_PLACA,
P_REMO_NUMERO_EJES,
P_REMO_NUMERO_LLANTAS_EJE,
P_REMO_PRESION_INFLADO_LLANTAS,
P_REMO_ESPROPIEDAD,
P_REMO_REGISTRADOPOR,
P_REMO_FECHACAMBIO,
P_REMO_PROCESOAUDITORIA
);

SELECT S_REMO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_SOLICARGAARCHIVO (
P_ARCH_ID IN SOLICITUDCARGAARCHIVO.ARCH_ID%TYPE,
P_SOLI_ID IN SOLICITUDCARGAARCHIVO.SOLI_ID%TYPE,
P_SCAR_REGISTRADOPOR IN SOLICITUDCARGAARCHIVO.SCAR_REGISTRADOPOR%TYPE,
P_SCAR_FECHACAMBIO IN SOLICITUDCARGAARCHIVO.SCAR_FECHACAMBIO%TYPE,
P_SCAR_PROCESOAUDITORIA IN SOLICITUDCARGAARCHIVO.SCAR_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLICITUDCARGAARCHIVO(
ARCH_ID,
SOLI_ID,
SCAR_REGISTRADOPOR,
SCAR_FECHACAMBIO,
SCAR_PROCESOAUDITORIA
)
VALUES (
P_ARCH_ID,
P_SOLI_ID,
P_SCAR_REGISTRADOPOR,
P_SCAR_FECHACAMBIO,
P_SCAR_PROCESOAUDITORIA
);

SELECT S_SCAR_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_SOLICIERREVIAAR (
P_ARCH_ID IN SOLICITUDCIERREVIAARCHIVO.ARCH_ID%TYPE,
P_SOLI_ID IN SOLICITUDCIERREVIAARCHIVO.SOLI_ID%TYPE,
P_SCVA_REGISTRADOPOR IN SOLICITUDCIERREVIAARCHIVO.SCVA_REGISTRADOPOR%TYPE,
P_SCVA_FECHACAMBIO IN SOLICITUDCIERREVIAARCHIVO.SCVA_FECHACAMBIO%TYPE,
P_SCVA_PROCESOAUDITORIA IN SOLICITUDCIERREVIAARCHIVO.SCVA_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLICITUDCIERREVIAARCHIVO(
ARCH_ID,
SOLI_ID,
SCVA_REGISTRADOPOR,
SCVA_FECHACAMBIO,
SCVA_PROCESOAUDITORIA
)
VALUES (
P_ARCH_ID,
P_SOLI_ID,
P_SCVA_REGISTRADOPOR,
P_SCVA_FECHACAMBIO,
P_SCVA_PROCESOAUDITORIA
);

SELECT S_SCVA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_SOLZONAARCHIVO (
P_ARCH_ID IN SOLICITUDZONAARCHIVO.ARCH_ID%TYPE,
P_SOLI_ID IN SOLICITUDZONAARCHIVO.SOLI_ID%TYPE,
P_SOZA_REGISTRADOPOR IN SOLICITUDZONAARCHIVO.SOZA_REGISTRADOPOR%TYPE,
P_SOZA_FECHACAMBIO IN SOLICITUDZONAARCHIVO.SOZA_FECHACAMBIO%TYPE,
P_SOZA_PROCESOAUDITORIA IN SOLICITUDZONAARCHIVO.SOZA_PROCESOAUDITORIA%TYPE,
P_SOZA_TIPO IN SOLICITUDZONAARCHIVO.SOZA_TIPO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.SOLICITUDZONAARCHIVO(
ARCH_ID,
SOLI_ID,
SOZA_REGISTRADOPOR,
SOZA_FECHACAMBIO,
SOZA_PROCESOAUDITORIA,
SOZA_TIPO
)
VALUES (
P_ARCH_ID,
P_SOLI_ID,
P_SOZA_REGISTRADOPOR,
P_SOZA_FECHACAMBIO,
P_SOZA_PROCESOAUDITORIA,
P_SOZA_TIPO
);


SELECT S_SOZA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_TIPO (
P_TIPO_DESCRIPCION IN TIPO.TIPO_DESCRIPCION%TYPE,
P_TIPO_REGISTRADOPOR IN TIPO.TIPO_REGISTRADOPOR%TYPE,
P_TIPO_FECHACAMBIO IN TIPO.TIPO_FECHACAMBIO%TYPE,
P_TIPO_PROCESOAUDITORIA IN TIPO.TIPO_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.TIPO(
TIPO_DESCRIPCION,
TIPO_REGISTRADOPOR,
TIPO_FECHACAMBIO,
TIPO_PROCESOAUDITORIA
)
VALUES (
P_TIPO_DESCRIPCION,
P_TIPO_REGISTRADOPOR,
P_TIPO_FECHACAMBIO,
P_TIPO_PROCESOAUDITORIA
);

SELECT S_TIPO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_TIPOCARGA (
P_TICA_NOMBRE IN TIPOCARGA.TICA_NOMBRE%TYPE,
P_TICA_DESCRIPCION IN TIPOCARGA.TICA_DESCRIPCION%TYPE,
P_TICA_PROCESOAUDITORIA IN TIPOCARGA.TICA_PROCESOAUDITORIA%TYPE,
P_TICA_REGISTRADOPOR IN TIPOCARGA.TICA_REGISTRADOPOR%TYPE,
P_TICA_FECHACAMBIO IN TIPOCARGA.TICA_FECHACAMBIO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.TIPOCARGA(
TICA_NOMBRE,
TICA_DESCRIPCION,
TICA_PROCESOAUDITORIA,
TICA_REGISTRADOPOR,
TICA_FECHACAMBIO
)
VALUES (
P_TICA_NOMBRE,
P_TICA_DESCRIPCION,
P_TICA_PROCESOAUDITORIA,
P_TICA_REGISTRADOPOR,
P_TICA_FECHACAMBIO
);

SELECT S_TICA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_TIPODOCUMENTO (
P_TIDO_DESCRIPCION IN TIPODOCUMENTO.TIDO_DESCRIPCION%TYPE,
P_TIDO_TIPOPERSONA IN TIPODOCUMENTO.TIDO_TIPOPERSONA%TYPE,
P_TIDO_ABREVIATURA IN TIPODOCUMENTO.TIDO_ABREVIATURA%TYPE,
P_TIDO_REGISTRADOPOR IN TIPODOCUMENTO.TIDO_REGISTRADOPOR%TYPE,
P_TIDO_FECHACAMBIO IN TIPODOCUMENTO.TIDO_FECHACAMBIO%TYPE,
P_TIDO_PROCESOAUDITORIA IN TIPODOCUMENTO.TIDO_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.TIPODOCUMENTO(
TIDO_DESCRIPCION,
TIDO_TIPOPERSONA,
TIDO_ABREVIATURA,
TIDO_REGISTRADOPOR,
TIDO_FECHACAMBIO,
TIDO_PROCESOAUDITORIA
)
VALUES (
P_TIDO_DESCRIPCION,
P_TIDO_TIPOPERSONA,
P_TIDO_ABREVIATURA,
P_TIDO_REGISTRADOPOR,
P_TIDO_FECHACAMBIO,
P_TIDO_PROCESOAUDITORIA
);

SELECT S_TIDO_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_TRAMITE (
P_TRAM_NOMBRE IN TRAMITE.TRAM_NOMBRE%TYPE,
P_TRAM_REGISTRADOPOR IN TRAMITE.TRAM_REGISTRADOPOR%TYPE,
P_TRAM_FECHACAMBIO IN TRAMITE.TRAM_FECHACAMBIO%TYPE,
P_TRAM_PROCESOAUDITORIA IN TRAMITE.TRAM_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.TRAMITE(
TRAM_NOMBRE,
TRAM_REGISTRADOPOR,
TRAM_FECHACAMBIO,
TRAM_PROCESOAUDITORIA
)
VALUES (
P_TRAM_NOMBRE,
P_TRAM_REGISTRADOPOR,
P_TRAM_FECHACAMBIO,
P_TRAM_PROCESOAUDITORIA
);

SELECT S_TRAM_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_USUARIO (
P_PERS_ID IN USUARIO.PERS_ID%TYPE,
P_USUA_DOCUMENTO IN USUARIO.USUA_DOCUMENTO%TYPE,
P_USUA_CONTRASENA IN USUARIO.USUA_CONTRASENA%TYPE,
P_USUA_REGISTRADOPOR IN USUARIO.USUA_REGISTRADOPOR%TYPE,
P_USUA_FECHACAMBIO IN USUARIO.USUA_FECHACAMBIO%TYPE,
P_USUA_PROCESOAUDITORIA IN USUARIO.USUA_PROCESOAUDITORIA%TYPE,
P_TIDO_ID IN USUARIO.TIDO_ID%TYPE,
P_USUA_ESTADO IN USUARIO.USUA_ESTADO%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.USUARIO(
PERS_ID,
USUA_DOCUMENTO,
USUA_CONTRASENA,
USUA_REGISTRADOPOR,
USUA_FECHACAMBIO,
USUA_PROCESOAUDITORIA,
TIDO_ID,
USUA_ESTADO
)
VALUES (
P_PERS_ID,
P_USUA_DOCUMENTO,
P_USUA_CONTRASENA,
P_USUA_REGISTRADOPOR,
P_USUA_FECHACAMBIO,
P_USUA_PROCESOAUDITORIA,
P_TIDO_ID,
P_USUA_ESTADO
);

SELECT S_USUA_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_VALORDIATRACA (
P_VIGE_ID IN VALORDIATRAMITECARGA.VIGE_ID%TYPE,
P_VDTC_ESTADO IN VALORDIATRAMITECARGA.VDTC_ESTADO%TYPE,
P_VDTC_REGISTRADOPOR IN VALORDIATRAMITECARGA.VDTC_REGISTRADOPOR%TYPE,
P_VDTC_FECHACAMBIO IN VALORDIATRAMITECARGA.VDTC_FECHACAMBIO%TYPE,
P_VDTC_PROCESOAUDITORIA IN VALORDIATRAMITECARGA.VDTC_PROCESOAUDITORIA%TYPE,
P_VDTC_VALOR IN VALORDIATRAMITECARGA.VDTC_VALOR%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.VALORDIATRAMITECARGA(
VIGE_ID,
VDTC_ESTADO,
VDTC_REGISTRADOPOR,
VDTC_FECHACAMBIO,
VDTC_PROCESOAUDITORIA,
VDTC_VALOR
)
VALUES (
P_VIGE_ID,
P_VDTC_ESTADO,
P_VDTC_REGISTRADOPOR,
P_VDTC_FECHACAMBIO,
P_VDTC_PROCESOAUDITORIA,
P_VDTC_VALOR
);

SELECT S_VDTC_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_VEHICULO (
P_VEHI_MARCA IN VEHICULO.VEHI_MARCA%TYPE,
P_VEHI_PLACA IN VEHICULO.VEHI_PLACA%TYPE,
P_VEHI_TIPOVEHICULO IN VEHICULO.VEHI_TIPOVEHICULO%TYPE,
P_VEHI_REGISTRADOPOR IN VEHICULO.VEHI_REGISTRADOPOR%TYPE,
P_VEHI_FECHACAMBIO IN VEHICULO.VEHI_FECHACAMBIO%TYPE,
P_VEHI_PROCESOAUDITORIA IN VEHICULO.VEHI_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.VEHICULO(
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
VEHI_REGISTRADOPOR,
VEHI_FECHACAMBIO,
VEHI_PROCESOAUDITORIA
)
VALUES (
P_VEHI_MARCA,
P_VEHI_PLACA,
P_VEHI_TIPOVEHICULO,
P_VEHI_REGISTRADOPOR,
P_VEHI_FECHACAMBIO,
P_VEHI_PROCESOAUDITORIA
);

SELECT S_VEHI_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRAMITE_I_VEHICULO_EXT (
P_VEHI_MARCA IN VEHICULO.VEHI_MARCA%TYPE,
P_VEHI_PLACA IN VEHICULO.VEHI_PLACA%TYPE,
P_VEHI_TIPOVEHICULO IN VEHICULO.VEHI_TIPOVEHICULO%TYPE,
P_VEHI_EJES  IN VEHICULO.VEHI_EJES%TYPE,
P_VEHI_LLANTAS  IN VEHICULO.VEHI_LLANTAS%TYPE,
P_VEHI_PRESION_INFLADO  IN VEHICULO.VEHI_PRESION_INFLADO%TYPE,
P_VEHI_REGISTRADOPOR IN VEHICULO.VEHI_REGISTRADOPOR%TYPE,
P_VEHI_FECHACAMBIO IN VEHICULO.VEHI_FECHACAMBIO%TYPE,
P_VEHI_PROCESOAUDITORIA IN VEHICULO.VEHI_PROCESOAUDITORIA%TYPE,
P_SESION IN VARCHAR2,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.VEHICULO(
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
VEHI_EJES,
VEHI_LLANTAS,
VEHI_PRESION_INFLADO,
VEHI_REGISTRADOPOR,
VEHI_FECHACAMBIO,
VEHI_PROCESOAUDITORIA
)
VALUES (
P_VEHI_MARCA,
P_VEHI_PLACA,
P_VEHI_TIPOVEHICULO,
P_VEHI_EJES,
P_VEHI_LLANTAS,
P_VEHI_PRESION_INFLADO,
P_VEHI_REGISTRADOPOR,
P_VEHI_FECHACAMBIO,
P_VEHI_PROCESOAUDITORIA
);

SELECT S_VEHI_ID.CURRVAL INTO P_RETORNO FROM DUAL;

END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_VEHICULOPAZYSALVO (
P_SOLI_ID IN VEHICULOPAZYSALVO.SOLI_ID%TYPE,
P_VEPS_REGISTRADOPOR IN VEHICULOPAZYSALVO.VEPS_REGISTRADOPOR%TYPE,
P_VEPS_FECHACAMBIO IN VEHICULOPAZYSALVO.VEPS_FECHACAMBIO%TYPE,
P_VEPS_PROCESOAUDITORIA IN VEHICULOPAZYSALVO.VEPS_PROCESOAUDITORIA%TYPE,
P_VEPS_ESTADO IN VEHICULOPAZYSALVO.VEPS_ESTADO%TYPE,
P_VEPS_PLACA IN VEHICULOPAZYSALVO.VEPS_PLACA%TYPE,
P_VEPS_TOTAL IN VEHICULOPAZYSALVO.VEPS_TOTAL%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.VEHICULOPAZYSALVO(
SOLI_ID,
VEPS_REGISTRADOPOR,
VEPS_FECHACAMBIO,
VEPS_PROCESOAUDITORIA,
VEPS_ESTADO,
VEPS_PLACA,
VEPS_TOTAL
)
VALUES (
P_SOLI_ID,
P_VEPS_REGISTRADOPOR,
P_VEPS_FECHACAMBIO,
P_VEPS_PROCESOAUDITORIA,
P_VEPS_ESTADO,
P_VEPS_PLACA,
P_VEPS_TOTAL
);

SELECT S_VEPS_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.PR_TRAMITE_I_VIGENCIA (
P_VIGE_ANIO IN VIGENCIA.VIGE_ANIO%TYPE,
P_VIGE_ESTADO IN VIGENCIA.VIGE_ESTADO%TYPE,
P_VIGE_REGISTRADOPOR IN VIGENCIA.VIGE_REGISTRADOPOR%TYPE,
P_VIGE_FECHACAMBIO IN VIGENCIA.VIGE_FECHACAMBIO%TYPE,
P_VIGE_PROCESOAUDITORIA IN VIGENCIA.VIGE_PROCESOAUDITORIA%TYPE,
P_RETORNO OUT NUMBER)
AS
E_ERROR EXCEPTION;
BEGIN

INSERT INTO tramite.VIGENCIA(
VIGE_ANIO,
VIGE_ESTADO,
VIGE_REGISTRADOPOR,
VIGE_FECHACAMBIO,
VIGE_PROCESOAUDITORIA
)
VALUES (
P_VIGE_ANIO,
P_VIGE_ESTADO,
P_VIGE_REGISTRADOPOR,
P_VIGE_FECHACAMBIO,
P_VIGE_PROCESOAUDITORIA
);

SELECT S_VIGE_ID.CURRVAL INTO P_RETORNO FROM DUAL;
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRASLADAR_ARCS_PERSONA (P_SESSION_ID VARCHAR, P_PERS_ID VARCHAR)
as
contador    NUMBER;
BEGIN
/*Se cuentan cuantos archivos existe en la tabla archivo_session */
select count(*) into contador  from archivo_session where arcs_session = P_SESSION_ID;

IF(contador < 1 ) THEN /*No existen registros*/
    RETURN;
END IF;
/*Se transfieren los archivos de la tabla ARCHIVO_SESSION a la tabla de ARCHIVO*/
/*En el campo arch_descripcion se inserta el tipo de archivo pasa al campo REGISTRADOPOR de la tabla archivo  temporalmente */
/*En el campo arch_session de la tabla archivo_session se para al campo descripcion */
INSERT INTO ARCHIVO(ARCH_EXTENSION,ARCH_NOMBRE,ARCH_ARCHIVO,ARCH_REGISTRADOPOR,ARCH_FECHACAMBIO,ARCH_PROCESOAUDITORIA,ARCH_DESCRIPCION) 
select ARCS_EXTENSION,ARCS_NOMBRE,ARCS_ARCHIVO,ARCS_DESCRIPCION,SYSDATE,ARCS_PROCESOAUDITORIA,ARCS_SESSION  
from archivo_session WHERE ARCS_SESSION =P_SESSION_ID;

/*Se marcan los otros archivos anteriores en estado cero es decir inactivos, para   que solo existen un archivo vigente*/
UPDATE PERSONA_ARCHIVO SET PEAR_ESTADO = 0 WHERE PERS_ID = P_PERS_ID AND PEAR_TIPO 
IN(SELECT ARCS_DESCRIPCION FROM archivo_session WHERE ARCS_SESSION =P_SESSION_ID );

/*Se establece el vinculo en */
INSERT INTO PERSONA_ARCHIVO(ARCH_ID,PERS_ID,PEAR_REGISTRADOPOR,PEAR_FECHACAMBIO,PEAR_PROCESOAUDITORIA,PEAR_TIPO,PEAR_ESTADO) 
SELECT ARCH_ID,P_PERS_ID,'7182',SYSDATE,ARCH_PROCESOAUDITORIA,ARCH_REGISTRADOPOR,1
FROM ARCHIVO WHERE ARCH_DESCRIPCION =P_SESSION_ID;

update archivo set ARCH_DESCRIPCION = 'Archivo Soporte' where ARCH_DESCRIPCION =P_SESSION_ID;

/*delete from archivo_session where arcs_session = P_SESSION_ID;*/

/*Se borran todos los archivos que se han trabajado en los dias anteriores*/
delete  from archivo_session where arcs_fechacambio < (sysdate-1) ;


commit;
  
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRASLADAR_ARCS_REMO (P_SESSION_ID VARCHAR, P_REMO_ID VARCHAR) 
as
contador    NUMBER;
BEGIN
select count(*) into contador  from archivo_session where arcs_session = P_SESSION_ID;

IF(contador < 1 ) THEN
    RETURN;
END IF;
INSERT INTO ARCHIVO(ARCH_EXTENSION,ARCH_NOMBRE,ARCH_ARCHIVO,ARCH_REGISTRADOPOR,ARCH_FECHACAMBIO,ARCH_PROCESOAUDITORIA,ARCH_DESCRIPCION) 
select ARCS_EXTENSION,ARCS_NOMBRE,ARCS_ARCHIVO,ARCS_DESCRIPCION,SYSDATE,ARCS_PROCESOAUDITORIA,ARCS_SESSION  
from archivo_session WHERE ARCS_SESSION =P_SESSION_ID;


UPDATE REMOLQUE_ARCHIVO SET REAR_ESTADO = 0 WHERE REMO_ID = P_REMO_ID AND REAR_TIPO 
IN(SELECT ARCS_DESCRIPCION FROM archivo_session WHERE ARCS_SESSION =P_SESSION_ID );

INSERT INTO REMOLQUE_ARCHIVO(ARCH_ID,REMO_ID,REAR_REGISTRADOPOR,REAR_FECHACAMBIO,REAR_PROCESOAUDITORIA,REAR_TIPO,REAR_ESTADO) 
SELECT ARCH_ID,P_REMO_ID,'7182',SYSDATE,ARCH_PROCESOAUDITORIA,ARCH_REGISTRADOPOR,1
FROM ARCHIVO WHERE ARCH_DESCRIPCION =P_SESSION_ID;


update archivo set ARCH_DESCRIPCION = 'Archivo Soporte' where ARCH_DESCRIPCION =P_SESSION_ID;

delete from archivo_session where arcs_session = P_SESSION_ID;

commit;
  
END;
/

CREATE OR REPLACE PROCEDURE         TRAMITE.PR_TRASLADAR_ARCS_VEHI (P_SESSION_ID VARCHAR, P_VEHI_ID VARCHAR) 
as
contador    NUMBER;
BEGIN
select count(*) into contador  from archivo_session where arcs_session = P_SESSION_ID;

IF(contador < 1 ) THEN
    RETURN;
END IF;
INSERT INTO ARCHIVO(ARCH_EXTENSION,ARCH_NOMBRE,ARCH_ARCHIVO,ARCH_REGISTRADOPOR,ARCH_FECHACAMBIO,ARCH_PROCESOAUDITORIA,ARCH_DESCRIPCION) 
select ARCS_EXTENSION,ARCS_NOMBRE,ARCS_ARCHIVO,ARCS_DESCRIPCION,SYSDATE,ARCS_PROCESOAUDITORIA,ARCS_SESSION  
from archivo_session WHERE ARCS_SESSION =P_SESSION_ID;
UPDATE VEHICULO_ARCHIVO SET VEAR_ESTADO = 0 WHERE VEHI_ID = P_VEHI_ID AND VEAR_TIPO 
IN(SELECT ARCS_DESCRIPCION FROM archivo_session WHERE ARCS_SESSION =P_SESSION_ID );

INSERT INTO VEHICULO_ARCHIVO(ARCH_ID,VEHI_ID,VEAR_REGISTRADOPOR,VEAR_FECHACAMBIO,VEAR_PROCESOAUDITORIA,VEAR_TIPO,VEAR_ESTADO) 
SELECT ARCH_ID,P_VEHI_ID,'7182',SYSDATE,ARCH_PROCESOAUDITORIA,ARCH_REGISTRADOPOR,1
FROM ARCHIVO WHERE ARCH_DESCRIPCION =P_SESSION_ID;

update archivo set ARCH_DESCRIPCION = 'Archivo Soporte' where ARCH_DESCRIPCION =P_SESSION_ID;

delete from archivo_session where arcs_session = P_SESSION_ID;

commit;
  
END;
/

CREATE TABLE tramite.pagospse (
    ppse_id              NUMBER NOT NULL,
    ppse_referencia      VARCHAR2(80 BYTE),
    ppse_cus             NUMBER NOT NULL,
    ppse_valor           NUMBER,
    ppse_estado          VARCHAR2(20 BYTE),
    ppse_fechapago       DATE,
    ppse_descripcion     VARCHAR2(80 BYTE),
    ppse_identificacion  VARCHAR2(50 BYTE),
    ppse_banco           VARCHAR2(50 BYTE),
    ppse_ciclo           NUMBER,
    ppse_fecharegistro   DATE DEFAULT sysdate,
    ppse_reportado       VARCHAR2(2 BYTE) DEFAULT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.pagospse_pk ON
    tramite.pagospse (
        ppse_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.pagospse
    ADD CONSTRAINT pagospse_pk PRIMARY KEY ( ppse_id )
        USING INDEX tramite.pagospse_pk;

CREATE OR REPLACE PROCEDURE         TRAMITE.REGISTRARPAGO (
   p_ppse_referencia       IN       VARCHAR2,
   p_ppse_cus              IN       NUMBER,
   p_ppse_valor            IN       NUMBER,
   p_ppse_estado           IN       VARCHAR2,
   p_ppse_fechapago        IN       VARCHAR2,
   p_ppse_descripcion      IN       VARCHAR2,
   p_ppse_identificacion   IN       VARCHAR2,
   p_ppse_banco            IN       VARCHAR2,
   p_ppse_ciclo            IN       NUMBER,
   p_retorno               OUT      VARCHAR2
)
AS
   e_error   EXCEPTION;
BEGIN

    Declare cus Number;
    Begin
        select Count(ppse_cus) into cus from pagospse where ppse_cus = p_ppse_cus and ppse_referencia = p_ppse_referencia;
     
    
   IF cus = 0 then    
   INSERT INTO tramite.pagospse
               (ppse_referencia, ppse_cus, ppse_valor, ppse_estado,
                ppse_fechapago,
                ppse_descripcion, ppse_identificacion, ppse_banco,
                ppse_ciclo
               )
        VALUES (p_ppse_referencia, p_ppse_cus, p_ppse_valor, p_ppse_estado,
                TO_DATE (p_ppse_fechapago, 'yyyy-MM-dd HH24:Mi:SS'),
                p_ppse_descripcion, p_ppse_identificacion, p_ppse_banco,
                p_ppse_ciclo
               );

    
    
   SELECT 'OK'
     INTO p_retorno
     FROM DUAL;
    else
    SELECT 'Ya se encuentra reportado'
     INTO p_retorno
     FROM DUAL;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      SELECT 'ERROR EN LA CARGA'
        INTO p_retorno
        FROM DUAL;
    END;
END;
/

CREATE OR REPLACE PROCEDURE           TRAMITE.SEND_MAIL (p_to        IN VARCHAR2,
                                       p_from      IN VARCHAR2,
                                       p_message   IN VARCHAR2,
                                       p_smtp_host IN VARCHAR2,
                                       p_smtp_port IN NUMBER DEFAULT 25)
AS
  l_mail_conn   UTL_SMTP.connection;
BEGIN
  l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  UTL_SMTP.helo(l_mail_conn, p_smtp_host);
  UTL_SMTP.mail(l_mail_conn, p_from);
  UTL_SMTP.rcpt(l_mail_conn, p_to);
  UTL_SMTP.data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.quit(l_mail_conn);
END;
/

CREATE TABLE tramite.alertsfo (
    days NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.archivos_tramite (
    solicitud    VARCHAR2(20 BYTE),
    f_solicitud  DATE,
    radicado     VARCHAR2(10 BYTE),
    solicitante  VARCHAR2(100 BYTE),
    placa        VARCHAR2(10 BYTE),
    remolque     VARCHAR2(400 BYTE),
    direccion    VARCHAR2(100 BYTE),
    ciudad       VARCHAR2(15 BYTE),
    lon          VARCHAR2(5 BYTE),
    ancho        VARCHAR2(5 BYTE),
    alto         VARCHAR2(5 BYTE),
    carga        VARCHAR2(500 BYTE),
    del          DATE,
    al           DATE,
    dias         NUMBER(*, 0),
    f_permiso    DATE,
    n_permiso    VARCHAR2(20 BYTE),
    n_consig     VARCHAR2(20 BYTE),
    f_consig     DATE,
    fecha_act    DATE,
    estado       VARCHAR2(2 BYTE),
    vr_permiso   VARCHAR2(20 BYTE),
    nit_cc       VARCHAR2(25 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.codigovia (
    covi_id      NUMBER(30) NOT NULL,
    covi_codigo  VARCHAR2(30 BYTE) NOT NULL,
    covi_nombre  VARCHAR2(200 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.codigovia_pk ON
    tramite.codigovia (
        covi_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.codigovia
    ADD CONSTRAINT codigovia_pk PRIMARY KEY ( covi_id )
        USING INDEX tramite.codigovia_pk;

CREATE TABLE tramite.ejecucion (
    scri_id     VARCHAR2(80 BYTE) NOT NULL,
    paqu_id     VARCHAR2(30 BYTE) NOT NULL,
    ejec_fecha  DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.ejec_pk ON
    tramite.ejecucion (
        scri_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.ejecucion
    ADD CONSTRAINT ejec_pk PRIMARY KEY ( scri_id )
        USING INDEX tramite.ejec_pk;

CREATE TABLE tramite.estadosolicitud_2012 (
    esso_id                NUMBER(30) NOT NULL,
    esso_descripcion       VARCHAR2(200 BYTE) NOT NULL,
    esso_tipoestado        VARCHAR2(30 BYTE) NOT NULL,
    esso_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    esso_fechacambio       DATE NOT NULL,
    esso_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.estadosolicitudsiguiente_2012 (
    esso_id_origen         NUMBER(30) NOT NULL,
    esso_id_destino        NUMBER(30) NOT NULL,
    essi_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    essi_fechacambio       DATE NOT NULL,
    essi_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.it_hits (
    count VARCHAR2(30 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE GLOBAL TEMPORARY TABLE tramite.mensajes (
    mens_mensaje  VARCHAR2(100 BYTE),
    mens_fecha    DATE
) ON COMMIT PRESERVE ROWS;

CREATE TABLE tramite.menu (
    menu_id             NUMBER(*, 0) NOT NULL,
    menu_nombre         VARCHAR2(50 BYTE) NOT NULL,
    menu_tipo           VARCHAR2(30 BYTE) NOT NULL,
    menu_codigosubmenu  NUMBER(*, 0),
    menu_estado         NUMBER(*, 0) NOT NULL,
    menu_page           VARCHAR2(80 BYTE),
    menu_icono          VARCHAR2(20 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.menu_pk ON
    tramite.menu (
        menu_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.menu
    ADD CONSTRAINT menu_pk PRIMARY KEY ( menu_id )
        USING INDEX tramite.menu_pk;

CREATE TABLE tramite.persona_cadena_verificacion (
    pers_id           NUMBER(30) NOT NULL,
    peca_cadena       VARCHAR2(30 BYTE) NOT NULL,
    peca_fechacambio  DATE NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.persona_cadena_verificacion_pk ON
    tramite.persona_cadena_verificacion (
        pers_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.persona_cadena_verificacion
    ADD CONSTRAINT persona_cadena_verificacion_pk PRIMARY KEY ( pers_id )
        USING INDEX tramite.persona_cadena_verificacion_pk;

CREATE TABLE tramite.sff_hits (
    count NUMBER(20)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.solicitudeventotipo (
    sevt_id           VARCHAR2(10 BYTE) NOT NULL,
    sevt_descripcion  VARCHAR2(50 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudeventotipo_pk ON
    tramite.solicitudeventotipo (
        sevt_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudeventotipo
    ADD CONSTRAINT solicitudeventotipo_pk PRIMARY KEY ( sevt_id )
        USING INDEX tramite.solicitudeventotipo_pk;

CREATE TABLE tramite.solicitudpermisoespecialnruta (
    ruta_id           NUMBER(8) NOT NULL,
    ruta_codvia       VARCHAR2(20 BYTE),
    ruta_nombre       VARCHAR2(400 BYTE),
    ruta_pr_inicial   VARCHAR2(20 BYTE),
    ruta_pr_final     VARCHAR2(20 BYTE),
    ruta_tramo        VARCHAR2(200 BYTE),
    ruta_sector       VARCHAR2(200 BYTE),
    ruta_entidad      VARCHAR2(50 BYTE),
    ruta_territorial  VARCHAR2(100 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialnru_pk ON
    tramite.solicitudpermisoespecialnruta (
        ruta_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialnruta
    ADD CONSTRAINT solicitudpermisoespecialnru_pk PRIMARY KEY ( ruta_id )
        USING INDEX tramite.solicitudpermisoespecialnru_pk;

CREATE TABLE tramite.solicitudpermisoespecialpuente (
    sept_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    sept_puente            VARCHAR2(1000 BYTE) NOT NULL,
    seru_fechacambio       DATE NOT NULL,
    seru_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    seru_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudpermisoespecialpue_pk ON
    tramite.solicitudpermisoespecialpuente (
        sept_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudpermisoespecialpuente
    ADD CONSTRAINT solicitudpermisoespecialpue_pk PRIMARY KEY ( sept_id )
        USING INDEX tramite.solicitudpermisoespecialpue_pk;

CREATE TABLE tramite.solicitudzonacarreteraarchivo (
    soza_id                NUMBER(30) NOT NULL,
    arch_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    soza_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    soza_fechacambio       DATE NOT NULL,
    soza_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    arch_tipo              NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 131072 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

COMMENT ON TABLE tramite.solicitudzonacarreteraarchivo IS
    'Almacena los archivos de las solicitudes de Uso Zona de Carretera';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.soza_id IS
    'ALMACENA EL IDENTIFICADOR DE LA TABLA';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.arch_id IS
    'ALMACENA EL IDENTIFICADOR DEL ARCHIVO';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.soli_id IS
    'ALMACENA EL IDENTIFICADOR DE LA SOLICITUD';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.soza_registradopor IS
    'campo de auditoria. este campo guarda el nombre del usuario que realizo el registro.';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.soza_fechacambio IS
    'campo de auditoria. este campo es la fecha en que se cambio el registro de la tabla.';

COMMENT ON COLUMN tramite.solicitudzonacarreteraarchivo.soza_procesoauditoria IS
    'campo de auditoria. este campo es el proceso con el cual se cambio el registro de la tabla.';

CREATE UNIQUE INDEX tramite.pk_soza ON
    tramite.solicitudzonacarreteraarchivo (
        soza_id
    ASC )
        TABLESPACE tramiteind PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 1048576 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudzonacarreteraarchivo
    ADD CONSTRAINT pk_soza PRIMARY KEY ( soza_id )
        USING INDEX tramite.pk_soza;

CREATE TABLE tramite.solicitudzonacarreterapr (
    szpr_id                NUMBER(30) NOT NULL,
    soli_id                NUMBER(30) NOT NULL,
    szpr_ruta              VARCHAR2(1000 BYTE) NOT NULL,
    szpr_geometria         VARCHAR2(1000 BYTE) NOT NULL,
    szpr_fechacambio       DATE NOT NULL,
    szpr_registradopor     VARCHAR2(30 BYTE) NOT NULL,
    szpr_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudzonacarreterapr_pk ON
    tramite.solicitudzonacarreterapr (
        szpr_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudzonacarreterapr
    ADD CONSTRAINT solicitudzonacarreterapr_pk PRIMARY KEY ( szpr_id )
        USING INDEX tramite.solicitudzonacarreterapr_pk;

CREATE TABLE tramite.solicitudzonacarreteratipo (
    szct_id                NUMBER(5) NOT NULL,
    szct_descripcion       VARCHAR2(200 BYTE),
    szct_registradopor     VARCHAR2(30 BYTE),
    szct_fechacambio       DATE,
    szct_procesoauditoria  VARCHAR2(300 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.solicitudzonacarreteratipo_pk ON
    tramite.solicitudzonacarreteratipo (
        szct_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.solicitudzonacarreteratipo
    ADD CONSTRAINT solicitudzonacarreteratipo_pk PRIMARY KEY ( szct_id )
        USING INDEX tramite.solicitudzonacarreteratipo_pk;

CREATE TABLE tramite.stdpermisoespecialarchobs (
    oape_id           NUMBER(8) NOT NULL,
    sope_id           NUMBER(8) NOT NULL,
    pers_id           NUMBER(8),
    oape_fechacambio  DATE DEFAULT sysdate NOT NULL,
    oape_observacion  VARCHAR2(4000 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.stdpermisoespecialarchobs_pk ON
    tramite.stdpermisoespecialarchobs (
        oape_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE TABLE tramite.stdpermisoespecialcalif (
    spec_id            NUMBER(8) NOT NULL,
    soli_id            NUMBER(8) NOT NULL,
    pers_id            NUMBER(8),
    spec_fechacambio   DATE DEFAULT sysdate NOT NULL,
    spec_observacion   VARCHAR2(4000 BYTE) NOT NULL,
    spec_calificacion  VARCHAR2(15 BYTE) NOT NULL,
    tipo_id            NUMBER(*, 0)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.stdpermisoespecialcalif_pk ON
    tramite.stdpermisoespecialcalif (
        spec_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

CREATE TABLE tramite.stdpermisoespecialrutases (
    sert_id           NUMBER(30) NOT NULL,
    sert_codvia       VARCHAR2(20 BYTE),
    sert_nombre       VARCHAR2(400 BYTE),
    sert_pr_inicial   VARCHAR2(20 BYTE),
    sert_pr_final     VARCHAR2(20 BYTE),
    sert_tramo        VARCHAR2(200 BYTE),
    sert_sector       VARCHAR2(200 BYTE),
    sert_entidad      VARCHAR2(50 BYTE),
    sert_territorial  VARCHAR2(100 BYTE),
    sert_ancho        NUMBER(5, 2),
    sert_altura       NUMBER(5, 2),
    sert_peso         NUMBER(5, 2),
    sert_longitud     NUMBER(5, 2),
    sert_parcial      NUMBER(*, 0),
    sert_descripcion  VARCHAR2(600 BYTE),
    sert_session      VARCHAR2(400 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE TABLE tramite.territorial (
    terr_id       NUMBER(30) NOT NULL,
    terr_nombre   VARCHAR2(100 BYTE) NOT NULL,
    esso_id_coes  NUMBER(30)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.territorial_pk ON
    tramite.territorial (
        terr_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.territorial
    ADD CONSTRAINT territorial_pk PRIMARY KEY ( terr_id )
        USING INDEX tramite.territorial_pk;

CREATE TABLE tramite.tipo_documento_soporte (
    tdsp_id         NUMBER(*, 0) NOT NULL,
    tdsp_name       VARCHAR2(150 BYTE) NOT NULL,
    tdsp_name_file  VARCHAR2(50 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.tipo_documento_soporte_pk ON
    tramite.tipo_documento_soporte (
        tdsp_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tipo_documento_soporte
    ADD CONSTRAINT tipo_documento_soporte_pk PRIMARY KEY ( tdsp_id )
        USING INDEX tramite.tipo_documento_soporte_pk;

CREATE TABLE tramite.toad_plan_table (
    statement_id       VARCHAR2(30 BYTE),
    plan_id            NUMBER,
    timestamp          DATE,
    remarks            VARCHAR2(4000 BYTE),
    operation          VARCHAR2(30 BYTE),
    options            VARCHAR2(255 BYTE),
    object_node        VARCHAR2(128 BYTE),
    object_owner       VARCHAR2(30 BYTE),
    object_name        VARCHAR2(30 BYTE),
    object_alias       VARCHAR2(65 BYTE),
    object_instance    NUMBER(*, 0),
    object_type        VARCHAR2(30 BYTE),
    optimizer          VARCHAR2(255 BYTE),
    search_columns     NUMBER,
    id                 NUMBER(*, 0),
    parent_id          NUMBER(*, 0),
    depth              NUMBER(*, 0),
    position           NUMBER(*, 0),
    cost               NUMBER(*, 0),
    cardinality        NUMBER(*, 0),
    bytes              NUMBER(*, 0),
    other_tag          VARCHAR2(255 BYTE),
    partition_start    VARCHAR2(255 BYTE),
    partition_stop     VARCHAR2(255 BYTE),
    partition_id       NUMBER(*, 0),
    other              LONG,
    distribution       VARCHAR2(30 BYTE),
    cpu_cost           NUMBER(*, 0),
    io_cost            NUMBER(*, 0),
    temp_space         NUMBER(*, 0),
    access_predicates  VARCHAR2(4000 BYTE),
    filter_predicates  VARCHAR2(4000 BYTE),
    projection         VARCHAR2(4000 BYTE),
    time               NUMBER(*, 0),
    qblock_name        VARCHAR2(30 BYTE),
    other_xml          CLOB
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
    LOB ( other_xml ) STORE AS (
        TABLESPACE tramitedat
        STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
        CHUNK 8192
        RETENTION
        ENABLE STORAGE IN ROW
        NOCACHE LOGGING
    );

GRANT DELETE, INSERT, SELECT, UPDATE ON tramite.toad_plan_table TO PUBLIC;

CREATE TABLE tramite.tramovia (
    trvi_codigo  VARCHAR2(30 BYTE) NOT NULL,
    trvi_nombre  VARCHAR2(150 BYTE) NOT NULL
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.tramovia_pk ON
    tramite.tramovia (
        trvi_codigo
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.tramovia
    ADD CONSTRAINT tramovia_pk PRIMARY KEY ( trvi_codigo )
        USING INDEX tramite.tramovia_pk;

CREATE TABLE tramite.usuariosolicitud (
    usso_id                NUMBER(30) NOT NULL,
    usso_cadena            VARCHAR2(100 BYTE) NOT NULL,
    usso_fechacreacion     DATE NOT NULL,
    usso_procesoauditoria  VARCHAR2(300 BYTE) NOT NULL,
    usso_tipo              NUMBER(30) NOT NULL,
    usua_id                NUMBER(30)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

CREATE UNIQUE INDEX tramite.usuariosolicitud_pk_usso_id ON
    tramite.usuariosolicitud (
        usso_id
    ASC )
        TABLESPACE tramitedat PCTFREE 10 MAXTRANS 255
            STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT )
        LOGGING;

ALTER TABLE tramite.usuariosolicitud
    ADD CONSTRAINT usuariosolicitud_pk_usso_id PRIMARY KEY ( usso_id )
        USING INDEX tramite.usuariosolicitud_pk_usso_id;

CREATE TABLE tramite.view_pago (
    placa          VARCHAR2(20 BYTE) NOT NULL,
    valor_evasion  NUMBER(30) NOT NULL,
    pago           VARCHAR2(1 BYTE)
)
PCTFREE 10 PCTUSED 40 MAXTRANS 255 TABLESPACE tramitedat LOGGING
    STORAGE ( INITIAL 65536 PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT );

ALTER TABLE tramite.cargamovilizadatipocarga
    ADD CONSTRAINT cmtp_camo_fk FOREIGN KEY ( camo_id )
        REFERENCES tramite.cargamovilizada ( camo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.cargamovilizadatipocarga
    ADD CONSTRAINT cmtp_tica_fk FOREIGN KEY ( tica_id )
        REFERENCES tramite.tipocarga ( tica_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.estadosolicitudsiguiente
    ADD CONSTRAINT estadosolicitudsiguiente_r01 FOREIGN KEY ( tram_id )
        REFERENCES tramite.tramite ( tram_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.stdpermisoespecialarchobs
    ADD CONSTRAINT fk_archobs_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.stdpermisoespecialarchobs
    ADD CONSTRAINT fk_archobs_sopearc_r01 FOREIGN KEY ( sope_id )
        REFERENCES tramite.solicitudpermisoespecialarch ( sope_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.consignacion
    ADD CONSTRAINT fk_cons_banc FOREIGN KEY ( banc_id )
        REFERENCES tramite.banco ( banc_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.consignacion
    ADD CONSTRAINT fk_cons_muni FOREIGN KEY ( muni_id,
                                              depa_id )
        REFERENCES tramite.municipio ( muni_id,
                                       depa_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.consignacion
    ADD CONSTRAINT fk_cons_soca FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.estadosolicitudsiguiente
    ADD CONSTRAINT fk_esss_esso_destino FOREIGN KEY ( esso_id_destino )
        REFERENCES tramite.estadosolicitud ( esso_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.estadosolicitudsiguiente
    ADD CONSTRAINT fk_esss_esso_origen FOREIGN KEY ( esso_id_origen )
        REFERENCES tramite.estadosolicitud ( esso_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.municipio
    ADD CONSTRAINT fk_muni_depa FOREIGN KEY ( depa_id )
        REFERENCES tramite.departamento ( depa_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personajuridica
    ADD CONSTRAINT fk_peju_pena FOREIGN KEY ( pers_idpersonanatural )
        REFERENCES tramite.personanatural ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personajuridica
    ADD CONSTRAINT fk_peju_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personanatural
    ADD CONSTRAINT fk_pena_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personaremolque
    ADD CONSTRAINT fk_pere_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personaremolque
    ADD CONSTRAINT fk_pere_remo FOREIGN KEY ( remo_id )
        REFERENCES tramite.remolque ( remo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.persona
    ADD CONSTRAINT fk_pers_muni FOREIGN KEY ( muni_id,
                                              depa_id )
        REFERENCES tramite.municipio ( muni_id,
                                       depa_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.persona
    ADD CONSTRAINT fk_pers_tido FOREIGN KEY ( tido_id )
        REFERENCES tramite.tipodocumento ( tido_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personavehiculo
    ADD CONSTRAINT fk_peve_vehi FOREIGN KEY ( vehi_id )
        REFERENCES tramite.vehiculo ( vehi_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.personavehiculo
    ADD CONSTRAINT fk_pevi_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.remolque_archivo
    ADD CONSTRAINT fk_remolque_archivo_archivo FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.remolque_archivo
    ADD CONSTRAINT fk_remolque_archivo_remolque FOREIGN KEY ( remo_id )
        REFERENCES tramite.remolque ( remo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcarga
    ADD CONSTRAINT fk_soca_camo FOREIGN KEY ( camo_id )
        REFERENCES tramite.cargamovilizada ( camo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcarga
    ADD CONSTRAINT fk_soca_peve FOREIGN KEY ( pers_id,
                                              vehi_id )
        REFERENCES tramite.personavehiculo ( pers_id,
                                             vehi_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcarga
    ADD CONSTRAINT fk_soca_soli FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcargaremolque
    ADD CONSTRAINT fk_socr_pere FOREIGN KEY ( remo_id,
                                              pers_id )
        REFERENCES tramite.personaremolque ( remo_id,
                                             pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcargaremolque
    ADD CONSTRAINT fk_socr_soca FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudcarga ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.programacionevento
    ADD CONSTRAINT fk_socv_prev FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudcierrevia ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcierrevia
    ADD CONSTRAINT fk_socv_soli FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudeventoarchivo
    ADD CONSTRAINT fk_soev_arch_arch FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudeventoarchivo
    ADD CONSTRAINT fk_soev_arch_soli FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudevento ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT fk_soli_pena FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudevento
    ADD CONSTRAINT fk_solivento_solicitud FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialarch
    ADD CONSTRAINT fk_sope_soli_solicitud FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solipazysalvoarchivo
    ADD CONSTRAINT fk_sops_veps FOREIGN KEY ( veps_id )
        REFERENCES tramite.vehiculopazysalvo ( veps_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpazysalvo
    ADD CONSTRAINT fk_sopz_soli FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudzonacarreteraarchivo
    ADD CONSTRAINT fk_soza_sozn FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudzonacarretera ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudzonacarretera
    ADD CONSTRAINT fk_sozc_soli FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.stdpermisoespecialcalif
    ADD CONSTRAINT fk_stdpermisoespecialcalif_02 FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.stdpermisoespecialcalif
    ADD CONSTRAINT fk_stdpermisoespecialcalif_r1 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudpermisoespecial ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.tipoestadosolicitud
    ADD CONSTRAINT fk_ties_esso FOREIGN KEY ( esso_id )
        REFERENCES tramite.estadosolicitud ( esso_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.tipoestadosolicitud
    ADD CONSTRAINT fk_ties_tipo FOREIGN KEY ( tipo_id )
        REFERENCES tramite.tipo ( tipo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.tramiteestadosolicitud
    ADD CONSTRAINT fk_tres_esso FOREIGN KEY ( esso_id )
        REFERENCES tramite.estadosolicitud ( esso_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.tramiteestadosolicitud
    ADD CONSTRAINT fk_tres_tram FOREIGN KEY ( tram_id )
        REFERENCES tramite.tramite ( tram_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.usuariotipo
    ADD CONSTRAINT fk_usti_tipo FOREIGN KEY ( tipo_id )
        REFERENCES tramite.tipo ( tipo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.usuariotipo
    ADD CONSTRAINT fk_usti_usua FOREIGN KEY ( usua_id )
        REFERENCES tramite.usuario ( usua_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.usuario
    ADD CONSTRAINT fk_usua_pers FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.usuario
    ADD CONSTRAINT fk_usua_tido FOREIGN KEY ( tido_id )
        REFERENCES tramite.tipodocumento ( tido_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.vehiculo_archivo
    ADD CONSTRAINT fk_vehiculo_archivo_archivo FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.vehiculo_archivo
    ADD CONSTRAINT fk_vehiculo_archivo_vehiculo FOREIGN KEY ( vehi_id )
        REFERENCES tramite.vehiculo ( vehi_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.vehiculopazysalvo
    ADD CONSTRAINT fk_veps_sops FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudpazysalvo ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.persona_archivo
    ADD CONSTRAINT persona_archivo_r01 FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.persona_archivo
    ADD CONSTRAINT persona_archivo_r02 FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.persona_cadena_verificacion
    ADD CONSTRAINT persona_cadena_verificacionr01 FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcargaarchivo
    ADD CONSTRAINT scar_soli_fk FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudcarga ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcierreviaarchivo
    ADD CONSTRAINT scva_archi_fk FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudcierreviaarchivo
    ADD CONSTRAINT scva_soli_fk FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudcierrevia ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitud
    ADD CONSTRAINT soli_tres_fk FOREIGN KEY ( tram_id,
                                              esso_id )
        REFERENCES tramite.tramiteestadosolicitud ( tram_id,
                                                    esso_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudestacion
    ADD CONSTRAINT solicitudestacion_r01 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudeventoetapa
    ADD CONSTRAINT solicitudeventoetapa_r01 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudevento ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudeventoetapavia
    ADD CONSTRAINT solicitudeventoetapavia_r01 FOREIGN KEY ( soli_id,
                                                             seet_numero )
        REFERENCES tramite.solicitudeventoetapa ( soli_id,
                                                  seet_numero )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecial
    ADD CONSTRAINT solicitudpermisoespecial_r01 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialarch
    ADD CONSTRAINT solicitudpermisoespecialar_r01 FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialpuente
    ADD CONSTRAINT solicitudpermisoespecialpu_r01 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudpermisoespecial ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialremo
    ADD CONSTRAINT solicitudpermisoespecialre_r01 FOREIGN KEY ( rear_id_licencia )
        REFERENCES tramite.remolque_archivo ( rear_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialremo
    ADD CONSTRAINT solicitudpermisoespecialre_r02 FOREIGN KEY ( remo_id )
        REFERENCES tramite.remolque ( remo_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialremo
    ADD CONSTRAINT solicitudpermisoespecialre_r03 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialremo
    ADD CONSTRAINT solicitudpermisoespecialre_r04 FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialve_r01 FOREIGN KEY ( vehi_id )
        REFERENCES tramite.vehiculo ( vehi_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialve_r02 FOREIGN KEY ( pers_id )
        REFERENCES tramite.persona ( pers_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialve_r03 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitud ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialve_r04 FOREIGN KEY ( vear_id_licencia )
        REFERENCES tramite.vehiculo_archivo ( vear_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudpermisoespecialvehi
    ADD CONSTRAINT solicitudpermisoespecialve_r05 FOREIGN KEY ( vear_id_catalogo )
        REFERENCES tramite.vehiculo_archivo ( vear_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudzonacarretera
    ADD CONSTRAINT solicitudzonacarretera_r01 FOREIGN KEY ( szct_id )
        REFERENCES tramite.solicitudzonacarreteratipo ( szct_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudzonacarreteraarchivo
    ADD CONSTRAINT solicitudzonacarreteraarch_r01 FOREIGN KEY ( arch_id )
        REFERENCES tramite.archivo ( arch_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.solicitudzonacarreterapr
    ADD CONSTRAINT solicitudzonacarreterapr_r01 FOREIGN KEY ( soli_id )
        REFERENCES tramite.solicitudzonacarretera ( soli_id )
    NOT DEFERRABLE;

ALTER TABLE tramite.valordiatramitecarga
    ADD CONSTRAINT vdtc_vige_fk FOREIGN KEY ( vige_id )
        REFERENCES tramite.vigencia ( vige_id )
    NOT DEFERRABLE;

CREATE OR REPLACE VIEW TRAMITE.INTERNET ( SOLI_ID, VEHI_PLACA, REMO_PLACA, SOCA_FECHAORIGEN, SOCA_FECHADESTINO, SOCA_DIASMOVILIZACION, SOLI_FECHA, SOCA_SEGURIDAD ) AS
SELECT SOL.SOLI_ID,VEH.VEHI_PLACA, REM.REMO_PLACA, SCA.SOCA_FECHAORIGEN, SCA.SOCA_FECHADESTINO,
SCA.SOCA_DIASMOVILIZACION, SOL.SOLI_FECHA,SCA.SOCA_SEGURIDAD
FROM TRAMITE.SOLICITUDCARGA SCA, TRAMITE.SOLICITUDCARGAREMOLQUE SRO, 
TRAMITE.VEHICULO VEH, REMOLQUE REM, SOLICITUD SOL
WHERE SCA.SOLI_ID=SRO.SOLI_ID
AND SRO.REMO_ID=REM.REMO_ID
AND SCA.VEHI_ID=VEH.VEHI_ID
AND SCA.SOLI_ID=SOL.SOLI_ID
AND SOL.ESSO_ID=64 
;

CREATE OR REPLACE VIEW TRAMITE.VIEW_PLACA_FECHA ( SOLI_ID, VEHI_PLACA, F_DESDE, F_HASTA, TOTAL_DIAS ) AS
SELECT ALL solicitudcarga.soli_id, vehiculo.vehi_placa,
              solicitudcarga.soca_fechaorigen AS f_desde,
              solicitudcarga.soca_fechadestino AS f_hasta,
              solicitudcarga.soca_diasmovilizacion AS total_dias
         FROM solicitudcarga INNER JOIN vehiculo
              ON solicitudcarga.vehi_id = vehiculo.vehi_id 
;

CREATE OR REPLACE VIEW TRAMITE.VIEW_SOLICITUD_ESTACION ( SOLI_ASIGNADO, SOLI_RADICADO, ESSO_ID, PERS_ID, SOLI_ID, SOLI_FECHACAMBIO, SOLI_FECHA, ESSO_DESCRIPCION, SOES_PROYECTO, SOLI_DESCCAMBIO ) AS
SELECT ST.SOLI_ASIGNADO,
          ST.SOLI_RADICADO,
          ST.ESSO_ID,
          ST.PERS_ID,
          st.soli_id,
          st.soli_fechacambio,
          ST.SOLI_FECHA,
          ES.ESSO_DESCRIPCION,
          SE.SOES_PROYECTO,
          ST.SOLI_DESCCAMBIO
     FROM solicitud st
          JOIN estadosolicitud es ON ES.ESSO_ID = ST.ESSO_ID
          JOIN solicitudestacion se ON SE.SOLI_ID = ST.SOLI_ID
    WHERE st.tram_id = 42 
;

CREATE OR REPLACE VIEW TRAMITE.VIEW_TRAMITE ( SOLI_ID, SOLI_RADICADO, VEHI_PLACA, SOLI_FECHA, NIT_CC, RAZON_SOCIAL, PRIMER_NOM, SEGUNDO_NOM, PRIMER_APEL, SEGUNDO_APEL, ESTADO, F_DESDE, F_HASTA, TOTAL_DIAS ) AS
SELECT ALL solicitud.soli_id, solicitud.soli_radicado,
              view_placa_fecha.vehi_placa, solicitud.soli_fecha,
              usuario.usua_documento AS nit_cc,
              personajuridica.peju_razonsocial AS razon_social,
              personanatural.pena_primernombre AS primer_nom,
              personanatural.pena_segundonombre AS segundo_nom,
              personanatural.pena_primerapellido AS primer_apel,
              personanatural.pena_segundoapellido AS segundo_apel,
              estadosolicitud.esso_descripcion AS estado,
              view_placa_fecha.f_desde, view_placa_fecha.f_hasta,
              view_placa_fecha.total_dias
         FROM ((((solicitud INNER JOIN usuario
              ON solicitud.pers_id = usuario.pers_id)
              INNER JOIN
              estadosolicitud ON solicitud.esso_id = estadosolicitud.esso_id)
              LEFT JOIN
              personajuridica ON solicitud.pers_id = personajuridica.pers_id)
              LEFT JOIN
              personanatural ON solicitud.pers_id = personanatural.pers_id)
              INNER JOIN
              view_placa_fecha ON solicitud.soli_id = view_placa_fecha.soli_id
        WHERE (((solicitud.soli_radicado) LIKE 'PECA_%'))
     ORDER BY solicitud.soli_radicado 
;

CREATE OR REPLACE VIEW TRAMITE.VIEW_TRAMITE_GRAL ( SOLI_ID, SOLI_RADICADO, VEHI_PLACA, SOLI_FECHA, NIT_CC, RAZON_SOCIAL, PRIMER_NOM, SEGUNDO_NOM, PRIMER_APEL, SEGUNDO_APEL, ESTADO, F_DESDE, F_HASTA, TOTAL_DIAS, CONS_NUMERO, CONS_FECHA, CONS_VALOR ) AS
SELECT   solicitud.soli_id, solicitud.soli_radicado,
            view_placa_fecha.vehi_placa, solicitud.soli_fecha,
            usuario.usua_documento AS nit_cc,
            personajuridica.peju_razonsocial AS razon_social,
            personanatural.pena_primernombre AS primer_nom,
            personanatural.pena_segundonombre AS segundo_nom,
            personanatural.pena_primerapellido AS primer_apel,
            personanatural.pena_segundoapellido AS segundo_apel,
            estadosolicitud.esso_descripcion AS estado,
            view_placa_fecha.f_desde, view_placa_fecha.f_hasta,
            view_placa_fecha.total_dias, consignacion.cons_numero,
            consignacion.cons_fecha, consignacion.cons_valor
       FROM (((((solicitud INNER JOIN usuario
            ON solicitud.pers_id = usuario.pers_id)
            INNER JOIN
            estadosolicitud ON solicitud.esso_id = estadosolicitud.esso_id)
            LEFT JOIN
            personajuridica ON solicitud.pers_id = personajuridica.pers_id)
            LEFT JOIN
            personanatural ON solicitud.pers_id = personanatural.pers_id)
            INNER JOIN
            view_placa_fecha ON solicitud.soli_id = view_placa_fecha.soli_id)
            INNER JOIN
            consignacion ON solicitud.soli_id = consignacion.soli_id
   ORDER BY solicitud.soli_radicado 
;

CREATE OR REPLACE VIEW TRAMITE.VIEWSOLICITUDEVENTOVO ( SOLI_ID, SOEV_DESCRIPCION, SOEV_FECHAINICIO, SOEV_FECHAFIN, SOEV_TIPOEVENTO, SOEV_NOMBREEVENTO, SOEV_ORGANIZACION, SOEV_DESCRIPCIONETAPA, SOEV_ESDEPORTIVO, SOEV_ESCICLISMO, SOEV_ESPROFESIONAL ) AS
select "SOLI_ID","SOEV_DESCRIPCION","SOEV_FECHAINICIO","SOEV_FECHAFIN","SOEV_TIPOEVENTO","SOEV_NOMBREEVENTO","SOEV_ORGANIZACION","SOEV_DESCRIPCIONETAPA","SOEV_ESDEPORTIVO","SOEV_ESCICLISMO","SOEV_ESPROFESIONAL" from solicitudevento 
;

CREATE OR REPLACE TRIGGER TRAMITE.PERSONA_ARCHIVO_TRG 
    BEFORE INSERT ON TRAMITE.PERSONA_ARCHIVO 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column PEAR_ID
  Select PERSONA_ARCHIVO_SEQ.nextval into n from dual;
  :new.PEAR_ID := N;
END PERSONA_ARCHIVO_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.REMOLQUE_ARCHIVO_TRG 
    BEFORE INSERT ON TRAMITE.REMOLQUE_ARCHIVO 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column REAR_ID
  Select REMOLQUE_ARCHIVO_SEQ.nextval into n from dual;
  :new.REAR_ID := N;
END REMOLQUE_ARCHIVO_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDEVENTOARCHIVO_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDEVENTOARCHIVO 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SEAR_ID
  Select SOLICITUDEVENTOARCHIVO_SEQ.nextval into n from dual;
  :new.SEAR_ID := N;
END SOLICITUDEVENTOARCHIVO_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDEVENTOETAPAVIA_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDEVENTOETAPAVIA 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SEVI_ID
  Select SOLICITUDEVENTOETAPAVIA2_SEQ.nextval into n from dual;
  :new.SEVI_ID := N;
END SOLICITUDEVENTOETAPAVIA_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDPERMISOESPECIALPU_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALPUENTE 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SEPT_ID
  Select SOLICITUDPERMISOESPECIALPU_SEQ.nextval into n from dual;
  :new.SEPT_ID := N;
END SOLICITUDPERMISOESPECIALPU_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDPERMISOESPECIALRE_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALREMO 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SERE_ID
  Select SOLICITUDPERMISOESPECIALR2_SEQ.nextval into n from dual;
  :new.SERE_ID := N;
END SOLICITUDPERMISOESPECIALRE_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDPERMISOESPECIALVE_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALVEHI 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SEVE_ID
  Select SOLICITUDPERMISOESPECIALVE_SEQ.nextval into n from dual;
  :new.SEVE_ID := N;
END SOLICITUDPERMISOESPECIALVE_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.SOLICITUDZONACARRETERAPR_TRG 
    BEFORE INSERT ON TRAMITE.SOLICITUDZONACARRETERAPR 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column SZPR_ID
  Select SOLICITUDZONACARRETERAPR2_SEQ.nextval into n from dual;
  :new.SZPR_ID := N;
END SOLICITUDZONACARRETERAPR_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.STDPERMISOESPECIALARCHOBS_TRG 
    BEFORE INSERT ON TRAMITE.STDPERMISOESPECIALARCHOBS 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column OAPE_ID
  Select STDPERMISOESPECIALARCHOBS_SEQ.nextval into n from dual;
  :new.OAPE_ID := N;
END STDPERMISOESPECIALARCHOBS_TRG; 
/

CREATE OR REPLACE TRIGGER TRAMITE.STDPERMISOESPECIALCALIF_TG 
    BEFORE INSERT ON TRAMITE.STDPERMISOESPECIALCALIF 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column OAPE_ID
  Select STDPERMISOESPECIALCALIF_SEQ.nextval into n from dual;
  :new.SPEC_ID := N;
END STDPERMISOESPECIALCALIF_TG;


/*Integridad referencial a la tabla solicitud permiso especial*/ ;
/

CREATE OR REPLACE TRIGGER TRAMITE.TG_STDPERMISOESPECIALRUTA 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALRUTA 
    FOR EACH ROW 
begin  
   if inserting then 
      if :NEW."SERU_ID" is null then 
         select SOLICITUDPERMISOESPECIALRU_SEQ.nextval into :NEW."SERU_ID" from dual; 
      end if; 
   end if; 
end; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TG_STDPERMISOESPECIALRUTASES 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALRTASES 
    FOR EACH ROW 
begin  
   if inserting then 
      if :NEW."SERT_ID" is null then 
         select SOLICITUDPERMISOESPECIALRU_SEQ.nextval into :NEW."SERT_ID" from dual; 
      end if; 
   end if; 
end; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_GVERGEL_I_SOLICITUD 
    AFTER INSERT ON TRAMITE.SOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUD(
ESSO_ID,
SOLI_ID,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.SOLI_ID,
:NEW.TRAM_ID,
:NEW.SOLI_REGISTRADOPOR,
:NEW.SOLI_FECHACAMBIO,
:NEW.SOLI_ACTIVARIMPRESION,
:NEW.SOLI_ACTIVO,
:NEW.SOLI_PROCESOAUDITORIA,
:NEW.SOLI_FECHA,
:NEW.PERS_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_GVERGEL_U_SOLICITUD 
    AFTER UPDATE ON TRAMITE.SOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUD(
ESSO_ID,
SOLI_ID,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.SOLI_ID,
:NEW.TRAM_ID,
:NEW.SOLI_REGISTRADOPOR,
:NEW.SOLI_FECHACAMBIO,
:NEW.SOLI_ACTIVARIMPRESION,
:NEW.SOLI_ACTIVO,
:NEW.SOLI_PROCESOAUDITORIA,
:NEW.SOLI_FECHA,
:NEW.PERS_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_I_PERMISOESPECIALNRUTA 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALNRUTA 
    FOR EACH ROW 
BEGIN
         SELECT PERMISOESPECIALNRUTA_SEQ.NEXTVAL INTO   :new.RUTA_ID FROM SYS.dual;
END; 



--------------------------------------------------------
--  DDL for Index SOLICITUDPERMISOESPECIALNRU_PK
-------------------------------------------------------- ;
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_ARCH_ID 
    BEFORE INSERT ON TRAMITE.ARCHIVO 
    FOR EACH ROW 
BEGIN
SELECT S_ARCH_ID.nextval
INTO globalPkg.identity
FROM dual;
 :new.ARCH_ID:= globalPkg.identity ;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_ARCS_ID 
    BEFORE INSERT ON TRAMITE.ARCHIVO_SESSION 
    FOR EACH ROW 
BEGIN
SELECT S_ARCS_ID.nextval
INTO globalPkg.identity
FROM dual;
 :new.ARCS_ID:= globalPkg.identity ;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_BANC_ID 
    BEFORE INSERT ON TRAMITE.BANCO 
    FOR EACH ROW 
BEGIN SELECT S_BANC_ID.nextval
INTO globalPkg.identity FROM dual; :new.BANC_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_CAMO_ID 
    BEFORE INSERT ON TRAMITE.CARGAMOVILIZADA 
    FOR EACH ROW 
BEGIN SELECT
S_CAMO_ID.nextval INTO globalPkg.identity FROM dual; :new.CAMO_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_CONS_ID 
    BEFORE INSERT ON TRAMITE.CONSIGNACION 
    FOR EACH ROW 
BEGIN SELECT
S_CONS_ID.nextval INTO globalPkg.identity FROM dual; :new.CONS_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_DEPA_ID 
    BEFORE INSERT ON TRAMITE.DEPARTAMENTO 
    FOR EACH ROW 
BEGIN SELECT
S_DEPA_ID.nextval INTO globalPkg.identity FROM dual; :new.DEPA_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_DNHC_ID_DIANOHABILCARGA 
    BEFORE INSERT ON TRAMITE.DIANOHABILCARGA 
    FOR EACH ROW 
BEGIN
SELECT S_DNHC_ID.nextval
INTO globalPkg.identity
FROM dual;
:new.DNHC_ID:= globalPkg.identity;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_MUNI_ID 
    BEFORE INSERT ON TRAMITE.MUNICIPIO 
    FOR EACH ROW 
BEGIN SELECT S_MUNI_ID.nextval
INTO globalPkg.identity FROM dual; :new.MUNI_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_PAGOSPSE 
    BEFORE INSERT ON TRAMITE.PAGOSPSE 
    FOR EACH ROW 
DECLARE
   estado     VARCHAR2 (20);
   ecode        VARCHAR2 (200);
   
   RESULT       BOOLEAN;
BEGIN

  SELECT s_pagospseid.NEXTVAL
     INTO globalpkg.identity
     FROM DUAL;

   :NEW.ppse_id := globalpkg.identity;    /*Asignacion de la clave principal*/

   /*Actualizar el estado de la solicitud*/
    SELECT ESSO_ID INTO estado FROM SOLICITUD WHERE  soli_id = :NEW.ppse_referencia;
    IF estado = '61' THEN /*Si esta en estado para pago*/
            /*Se actualiza la solicitud a un nuevo estado */
           UPDATE solicitud
              SET soli_asignado =
                     (SELECT tes.pers_id
                        FROM tramiteestadosolicitud tes,
                             solicitud sc,
                             estadosolicitudsiguiente ess
                       WHERE sc.esso_id = ess.esso_id_origen
                         AND tes.esso_id = ess.esso_id_destino
                         AND tes.tram_id = sc.tram_id
                         AND ess.tram_id = sc.tram_id
                         AND ess.esso_id_destino <> 65
                         AND sc.soli_id = :NEW.ppse_referencia),
                  esso_id =
                     (SELECT ess.esso_id_destino
                        FROM solicitud sc, estadosolicitudsiguiente ess
                       WHERE sc.esso_id = ess.esso_id_origen
                         AND ess.tram_id = sc.tram_id
                         AND soli_id = :NEW.ppse_referencia
                         AND ess.esso_id_destino <> 65),
                  soli_nomcambio = 'Pagos PSE'
            WHERE solicitud.soli_id = :NEW.ppse_referencia;
 
           /*Se actualiza el estado de la consignacion con el numero de consignacion CUS de ACH*/
           UPDATE consignacion
              SET cons_numero = :NEW.ppse_cus
            WHERE soli_id = :NEW.ppse_referencia;

           /*Inserta en la tabla MODS*/
           INSERT INTO mods
                       (soli_id, mod_desccambio, mod_nomcambio,
                        mod_fechacambio
                       )
                VALUES (:NEW.ppse_referencia, 'Registro de pago PSE', 'Sistema PSE',
                        SYSDATE
                       );
    END IF; 

EXCEPTION
    WHEN OTHERS THEN
    ecode := SQLCODE;
    dbms_output.put_line('TRS PAGOSPSE - ' || ecode);    
    RESULT := FALSE;
      
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_PARA_ID 
    BEFORE INSERT ON TRAMITE.PARAMETRIZACION 
    FOR EACH ROW 
BEGIN SELECT
S_PARA_ID.nextval INTO globalPkg.identity FROM dual; :new.PARA_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_PERS_ID 
    BEFORE INSERT ON TRAMITE.PERSONA 
    FOR EACH ROW 
BEGIN SELECT S_PERS_ID.nextval
INTO globalPkg.identity FROM dual; :new.PERS_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_PREV_ID 
    BEFORE INSERT ON TRAMITE.PROGRAMACIONEVENTO 
    FOR EACH ROW 
BEGIN SELECT
S_PREV_ID.nextval INTO globalPkg.identity FROM dual; :new.PREV_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_REMO_ID 
    BEFORE INSERT ON TRAMITE.REMOLQUE 
    FOR EACH ROW 
BEGIN SELECT S_REMO_ID.nextval
INTO globalPkg.identity FROM dual; :new.REMO_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SCAR_ID_SOLICARGAARCHIVO 
    BEFORE INSERT ON TRAMITE.SOLICITUDCARGAARCHIVO 
    FOR EACH ROW 
BEGIN
SELECT S_SCAR_ID.nextval
INTO globalPkg.identity
FROM dual;
:new.SCAR_ID:= globalPkg.identity;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SCVA_ID_SOLICIERREVIAAR 
    BEFORE INSERT ON TRAMITE.SOLICITUDCIERREVIAARCHIVO 
    FOR EACH ROW 
BEGIN
SELECT S_SCVA_ID.nextval
INTO globalPkg.identity
FROM dual;
:new.SCVA_ID:= globalPkg.identity;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SOLI_ID 
    BEFORE INSERT ON TRAMITE.SOLICITUD 
    FOR EACH ROW 
BEGIN SELECT S_SOLI_ID.nextval
INTO globalPkg.identity FROM dual; :new.SOLI_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SOPE_ID 
    BEFORE INSERT ON TRAMITE.SOLICITUDPERMISOESPECIALARCH 
    FOR EACH ROW 
BEGIN SELECT S_SOPEARCHIVO.nextval
INTO globalPkg.identity FROM dual; :new.SOPE_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SOZA_ID 
    BEFORE INSERT ON TRAMITE.SOLICITUDZONACARRETERAARCHIVO 
    FOR EACH ROW 
BEGIN SELECT
S_SOZA_ID.nextval INTO globalPkg.identity FROM dual; :new.SOZA_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_SPSA_ID 
    BEFORE INSERT ON TRAMITE.SOLIPAZYSALVOARCHIVO 
    FOR EACH ROW 
BEGIN SELECT
S_SPSA_ID.nextval INTO globalPkg.identity FROM dual; :new.SPSA_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_TICA_ID_TIPOCARGA 
    BEFORE INSERT ON TRAMITE.TIPOCARGA 
    FOR EACH ROW 
BEGIN
SELECT S_TICA_ID.nextval
INTO globalPkg.identity
FROM dual;
:new.TICA_ID:= globalPkg.identity;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_TIDO_ID 
    BEFORE INSERT ON TRAMITE.TIPODOCUMENTO 
    FOR EACH ROW 
BEGIN SELECT
S_TIDO_ID.nextval INTO globalPkg.identity FROM dual; :new.TIDO_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_TRAM_ID 
    BEFORE INSERT ON TRAMITE.TRAMITE 
    FOR EACH ROW 
BEGIN SELECT S_TRAM_ID.nextval
INTO globalPkg.identity FROM dual; :new.TRAM_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_USSO_ID 
    BEFORE INSERT ON TRAMITE.USUARIOSOLICITUD 
    FOR EACH ROW 
BEGIN
SELECT S_USSO_ID.nextval
INTO globalPkg.identity
FROM dual;
 :new.USSO_ID:= globalPkg.identity ;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_USUA_ID 
    BEFORE INSERT ON TRAMITE.USUARIO 
    FOR EACH ROW 
BEGIN SELECT S_USUA_ID.nextval
INTO globalPkg.identity FROM dual; :new.USUA_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_VDTC_ID_VALORDIATRACARGA 
    BEFORE INSERT ON TRAMITE.VALORDIATRAMITECARGA 
    FOR EACH ROW 
BEGIN
SELECT S_VDTC_ID.nextval
INTO globalPkg.identity
FROM dual;
:new.VDTC_ID:= globalPkg.identity;
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_VEHI_ID 
    BEFORE INSERT ON TRAMITE.VEHICULO 
    FOR EACH ROW 
BEGIN SELECT S_VEHI_ID.nextval
INTO globalPkg.identity FROM dual; :new.VEHI_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_VEPS_ID 
    BEFORE INSERT ON TRAMITE.VEHICULOPAZYSALVO 
    FOR EACH ROW 
BEGIN SELECT
S_VEPS_ID.nextval INTO globalPkg.identity FROM dual; :new.VEPS_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_S_VIGE_ID 
    BEFORE INSERT ON TRAMITE.VIGENCIA 
    FOR EACH ROW 
BEGIN SELECT S_VIGE_ID.nextval
INTO globalPkg.identity FROM dual; :new.VIGE_ID:= globalPkg.identity ; END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_ARCHIVO 
    AFTER INSERT ON TRAMITE.ARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ARCHIVO(
ARCH_ID,
ARCH_EXTENSION,
ARCH_NOMBRE,
ARCH_ARCHIVO,
ARCH_REGISTRADOPOR,
ARCH_FECHACAMBIO,
ARCH_PROCESOAUDITORIA,
ARCH_DESCRIPCION,
ARCH_OPERACION
)
VALUES (
:NEW.ARCH_ID,
:NEW.ARCH_EXTENSION,
:NEW.ARCH_NOMBRE,
null,
:NEW.ARCH_REGISTRADOPOR,
:NEW.ARCH_FECHACAMBIO,
:NEW.ARCH_PROCESOAUDITORIA,
:NEW.ARCH_DESCRIPCION,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_BANCO 
    AFTER INSERT ON TRAMITE.BANCO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_BANCO(
BANC_ID,
BANC_NOMBRE,
BANC_REGISTRADOPOR,
BANC_FECHACAMBIO,
BANC_PROCESOAUDITORIA,
BANC_OPERACION
)
VALUES (
:NEW.BANC_ID,
:NEW.BANC_NOMBRE,
:NEW.BANC_REGISTRADOPOR,
:NEW.BANC_FECHACAMBIO,
:NEW.BANC_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_CARGAMOTICA 
    AFTER INSERT ON TRAMITE.CARGAMOVILIZADATIPOCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CARGAMOVILIZADATIPOCARGA(
TICA_ID,
CAMO_ID,
CMTC_REGISTRADOPOR,
CMTC_FECHACAMBIO,
CMTC_PROCESOAUDITORIA,
CMTC_OPERACION
)
VALUES (
:NEW.TICA_ID,
:NEW.CAMO_ID,
:NEW.CMTC_REGISTRADOPOR,
:NEW.CMTC_FECHACAMBIO,
:NEW.CMTC_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_CARGAMOVILIZADA 
    AFTER INSERT ON TRAMITE.CARGAMOVILIZADA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CARGAMOVILIZADA(
CAMO_ID,
CAMO_ANCHO,
CAMO_ALTO,
CAMO_LONGITUDSOBRESALIENTE,
CAMO_REGISTRADOPOR,
CAMO_FECHACAMBIO,
CAMO_PROCESOAUDITORIA,
CAMO_OPERACION,
CAMO_PESO
)
VALUES (
:NEW.CAMO_ID,
:NEW.CAMO_ANCHO,
:NEW.CAMO_ALTO,
:NEW.CAMO_LONGITUDSOBRESALIENTE,
:NEW.CAMO_REGISTRADOPOR,
:NEW.CAMO_FECHACAMBIO,
:NEW.CAMO_PROCESOAUDITORIA,
'I',
:NEW.CAMO_PESO);
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_CONSIGNACION 
    AFTER INSERT ON TRAMITE.CONSIGNACION 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CONSIGNACION(
CONS_COMPROINGRESO,
CONS_ID,
BANC_ID,
MUNI_ID,
DEPA_ID,
CONS_VALOR,
CONS_FECHA,
CONS_NUMERO,
CONS_REGISTRADOPOR,
CONS_FECHACAMBIO,
CONS_PROCESOAUDITORIA,
SOLI_ID,
CONS_OPERACION
)
VALUES (
:NEW.CONS_COMPROINGRESO,
:NEW.CONS_ID,
:NEW.BANC_ID,
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.CONS_VALOR,
:NEW.CONS_FECHA,
:NEW.CONS_NUMERO,
:NEW.CONS_REGISTRADOPOR,
:NEW.CONS_FECHACAMBIO,
:NEW.CONS_PROCESOAUDITORIA,
:NEW.SOLI_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_DEPARTAMENTO 
    AFTER INSERT ON TRAMITE.DEPARTAMENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_DEPARTAMENTO(
DEPA_ID,
DEPA_NOMBRE,
DEPA_REGISTRADOPOR,
DEPA_FECHACAMBIO,
DEPA_PROCESOAUDITORIA,
DEPA_OPERACION
)
VALUES (
:NEW.DEPA_ID,
:NEW.DEPA_NOMBRE,
:NEW.DEPA_REGISTRADOPOR,
:NEW.DEPA_FECHACAMBIO,
:NEW.DEPA_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_DIANOHABILCARGA 
    AFTER INSERT ON TRAMITE.DIANOHABILCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_DIANOHABILCARGA(
DNHC_ID,
DNHC_FECHA,
DNHC_PROCESOAUDITORIA,
DNHC_REGISTRADOPOR,
DNHC_FECHACAMBIO,
DNHC_OPERACION
)
VALUES (
:NEW.DNHC_ID,
:NEW.DNHC_FECHA,
:NEW.DNHC_PROCESOAUDITORIA,
:NEW.DNHC_REGISTRADOPOR,
:NEW.DNHC_FECHACAMBIO,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_ESTADOSOLICITUD 
    AFTER INSERT ON TRAMITE.ESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ESTADOSOLICITUD(
ESSO_ID,
ESSO_DESCRIPCION,
ESSO_TIPOESTADO,
ESSO_REGISTRADOPOR,
ESSO_FECHACAMBIO,
ESSO_PROCESOAUDITORIA,
ESSO_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.ESSO_DESCRIPCION,
:NEW.ESSO_TIPOESTADO,
:NEW.ESSO_REGISTRADOPOR,
:NEW.ESSO_FECHACAMBIO,
:NEW.ESSO_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_ESTADOSOLICSIG 
    AFTER INSERT ON TRAMITE.ESTADOSOLICITUDSIGUIENTE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ESTADOSOLICITUDSIGUIENTE(
ESSO_ID_ORIGEN,
ESSO_ID_DESTINO,
ESSI_REGISTRADOPOR,
ESSI_FECHACAMBIO,
ESSI_PROCESOAUDITORIA,
ESSI_OPERACION
)
VALUES (
:NEW.ESSO_ID_ORIGEN,
:NEW.ESSO_ID_DESTINO,
:NEW.ESSI_REGISTRADOPOR,
:NEW.ESSI_FECHACAMBIO,
:NEW.ESSI_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_MUNICIPIO 
    AFTER INSERT ON TRAMITE.MUNICIPIO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_MUNICIPIO(
MUNI_ID,
DEPA_ID,
MUNI_NOMBRE,
MUNI_REGISTRADOPOR,
MUNI_FECHACAMBIO,
MUNI_PROCESOAUDITORIA,
MUNI_OPERACION
)
VALUES (
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.MUNI_NOMBRE,
:NEW.MUNI_REGISTRADOPOR,
:NEW.MUNI_FECHACAMBIO,
:NEW.MUNI_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PARAMETRIZACION 
    AFTER INSERT ON TRAMITE.PARAMETRIZACION 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PARAMETRIZACION(
PARA_REDVIAL,
PARA_ANCHO,
PARA_ALTO,
PARA_LONGITUDSOBRESALIENTE,
PARA_LEYENDA,
PARA_URLAPLICATIVO,
PARA_ID,
PARA_PAGOELECTRONICO,
PARA_IMPRESIONRECIBOPAG,
PARA_SOLITRANSPORTECARG,
PARA_SOLIUSOZONACARRETE,
PARA_SOLICIERREVIA,
PARA_SOLIPAZYSALVO,
PARA_REGISTRADOPOR,
PARA_FECHACAMBIO,
PARA_PROCESOAUDITORIA,
PARA_CORREOREMITENTE,
PARA_OPERACION,
PARA_ESFITRAMITECARGA,
PARA_PESO,
PARA_CARGO,
PARA_FUNCIONARIO
)
VALUES (
:NEW.PARA_REDVIAL,
:NEW.PARA_ANCHO,
:NEW.PARA_ALTO,
:NEW.PARA_LONGITUDSOBRESALIENTE,
:NEW.PARA_LEYENDA,
:NEW.PARA_URLAPLICATIVO,
:NEW.PARA_ID,
:NEW.PARA_PAGOELECTRONICO,
:NEW.PARA_IMPRESIONRECIBOPAG,
:NEW.PARA_SOLITRANSPORTECARG,
:NEW.PARA_SOLIUSOZONACARRETE,
:NEW.PARA_SOLICIERREVIA,
:NEW.PARA_SOLIPAZYSALVO,
:NEW.PARA_REGISTRADOPOR,
:NEW.PARA_FECHACAMBIO,
:NEW.PARA_PROCESOAUDITORIA,
:NEW.PARA_CORREOREMITENTE,
'I',
:NEW.PARA_ESFITRAMITECARGA,
:NEW.PARA_PESO,
:NEW.PARA_CARGO,
:NEW.PARA_FUNCIONARIO);
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PERSONA 
    AFTER INSERT ON TRAMITE.PERSONA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONA(
PERS_ID,
TIDO_ID,
MUNI_ID,
DEPA_ID,
PERS_DOCUMENTOIDENTIDAD,
PERS_DIRECCION,
PERS_TELEFONO,
PERS_CORREOELECTRONICO,
PERS_FAX,
PERS_REGISTRADOPOR,
PERS_FECHACAMBIO,
PERS_PROCESOAUDITORIA,
PERS_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.TIDO_ID,
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.PERS_DOCUMENTOIDENTIDAD,
:NEW.PERS_DIRECCION,
:NEW.PERS_TELEFONO,
:NEW.PERS_CORREOELECTRONICO,
:NEW.PERS_FAX,
:NEW.PERS_REGISTRADOPOR,
:NEW.PERS_FECHACAMBIO,
:NEW.PERS_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PERSONAJURIDICA 
    AFTER INSERT ON TRAMITE.PERSONAJURIDICA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAJURIDICA(
PERS_ID,
PERS_IDPERSONANATURAL,
PEJU_RAZONSOCIAL,
PEJU_CODIGOREPRESENTANTE,
PEJU_REGISTRADOPOR,
PEJU_FECHACAMBIO,
PEJU_PROCESOAUDITORIA,
PEJU_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.PERS_IDPERSONANATURAL,
:NEW.PEJU_RAZONSOCIAL,
:NEW.PEJU_CODIGOREPRESENTANTE,
:NEW.PEJU_REGISTRADOPOR,
:NEW.PEJU_FECHACAMBIO,
:NEW.PEJU_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PERSONANATURAL 
    AFTER INSERT ON TRAMITE.PERSONANATURAL 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONANATURAL(
PERS_ID,
PENA_PRIMERNOMBRE,
PENA_SEGUNDONOMBRE,
PENA_PRIMERAPELLIDO,
PENA_SEGUNDOAPELLIDO,
PENA_REGISTRADOPOR,
PENA_FECHACAMBIO,
PENA_PROCESOAUDITORIA,
PENA_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.PENA_PRIMERNOMBRE,
:NEW.PENA_SEGUNDONOMBRE,
:NEW.PENA_PRIMERAPELLIDO,
:NEW.PENA_SEGUNDOAPELLIDO,
:NEW.PENA_REGISTRADOPOR,
:NEW.PENA_FECHACAMBIO,
:NEW.PENA_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PERSONAREMOLQUE 
    AFTER INSERT ON TRAMITE.PERSONAREMOLQUE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAREMOLQUE(
REMO_ID,
PERE_FECHACAMBIO,
PERE_REGISTRADOPOR,
PERE_PROCESOAUDITORIA,
PERS_ID,
PERE_OPERACION
)
VALUES (
:NEW.REMO_ID,
:NEW.PERE_FECHACAMBIO,
:NEW.PERE_REGISTRADOPOR,
:NEW.PERE_PROCESOAUDITORIA,
:NEW.PERS_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PERSONAVEHICULO 
    AFTER INSERT ON TRAMITE.PERSONAVEHICULO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAVEHICULO(
PEVE_FECHACAMBIO,
PEVE_REGISTRADOPOR,
PEVE_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
PEVE_OPERACION
)
VALUES (
:NEW.PEVE_FECHACAMBIO,
:NEW.PEVE_REGISTRADOPOR,
:NEW.PEVE_PROCESOAUDITORIA,
:NEW.PERS_ID,
:NEW.VEHI_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_PROGEVENTO 
    AFTER INSERT ON TRAMITE.PROGRAMACIONEVENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PROGRAMACIONEVENTO(
PREV_ID,
PREV_MUNICIPIOSALIDA,
PREV_MUNICIPIOLLEGADA,
PREV_FECHA,
PREV_HORASALIDA,
PREV_HORALLEGADA,
PREV_LUGARSALIDA,
PREV_LUGARLLEGADA,
PREV_FECHACAMBIO,
PREV_PROCESOAUDITORIA,
PREV_REGISTRADOPOR,
SOLI_ID,
PREV_OPERACION
)
VALUES (
:NEW.PREV_ID,
:NEW.PREV_MUNICIPIOSALIDA,
:NEW.PREV_MUNICIPIOLLEGADA,
:NEW.PREV_FECHA,
:NEW.PREV_HORASALIDA,
:NEW.PREV_HORALLEGADA,
:NEW.PREV_LUGARSALIDA,
:NEW.PREV_LUGARLLEGADA,
:NEW.PREV_FECHACAMBIO,
:NEW.PREV_PROCESOAUDITORIA,
:NEW.PREV_REGISTRADOPOR,
:NEW.SOLI_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_REMOLQUE 
    AFTER INSERT ON TRAMITE.REMOLQUE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_REMOLQUE(
REMO_ID,
REMO_PLACA,
REMO_REGISTRADOPOR,
REMO_FECHACAMBIO,
REMO_PROCESOAUDITORIA,
REMO_OPERACION
)
VALUES (
:NEW.REMO_ID,
:NEW.REMO_PLACA,
:NEW.REMO_REGISTRADOPOR,
:NEW.REMO_FECHACAMBIO,
:NEW.REMO_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICARGAARCHIVO 
    AFTER INSERT ON TRAMITE.SOLICITUDCARGAARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCARGAARCHIVO(
SCAR_ID,
ARCH_ID,
SOLI_ID,
SCAR_REGISTRADOPOR,
SCAR_FECHACAMBIO,
SCAR_PROCESOAUDITORIA,
SCAR_OPERACION
)
VALUES (
:NEW.SCAR_ID,
:NEW.ARCH_ID,
:NEW.SOLI_ID,
:NEW.SCAR_REGISTRADOPOR,
:NEW.SCAR_FECHACAMBIO,
:NEW.SCAR_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICCIERREVIA 
    AFTER INSERT ON TRAMITE.SOLICITUDCIERREVIA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCIERREVIA(
SOLI_ID,
SOCV_NOMBREEVENTO,
SOCV_AVALADOPOR,
SOCV_RECORRIDOPROGRAMADO,
SOCV_REGISTRADOPOR,
SOCV_FECHACAMBIO,
SOCV_PROCESOAUDITORIA,
SOCV_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.SOCV_NOMBREEVENTO,
:NEW.SOCV_AVALADOPOR,
:NEW.SOCV_RECORRIDOPROGRAMADO,
:NEW.SOCV_REGISTRADOPOR,
:NEW.SOCV_FECHACAMBIO,
:NEW.SOCV_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICIERREVIAAR 
    AFTER INSERT ON TRAMITE.SOLICITUDCIERREVIAARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCIERREVIAARCHIVO(
SCVA_ID,
ARCH_ID,
SOLI_ID,
SCVA_REGISTRADOPOR,
SCVA_FECHACAMBIO,
SCVA_PROCESOAUDITORIA,
SCVA_OPERACION
)
VALUES (
:NEW.SCVA_ID,
:NEW.ARCH_ID,
:NEW.SOLI_ID,
:NEW.SCVA_REGISTRADOPOR,
:NEW.SCVA_FECHACAMBIO,
:NEW.SCVA_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICITUD 
    AFTER INSERT ON TRAMITE.SOLICITUD 
    FOR EACH ROW 
BEGIN 
INSERT 
INTO 
    TRAMITE.AUD_SOLICITUD 
    ( 
        ESSO_ID, 
        SOLI_ID, 
        TRAM_ID, 
        SOLI_REGISTRADOPOR, 
        SOLI_FECHACAMBIO, 
        SOLI_ACTIVARIMPRESION, 
        SOLI_ACTIVO, 
        SOLI_PROCESOAUDITORIA, 
        SOLI_FECHA, 
        PERS_ID, 
        SOLI_RADICADO, 
        SOLI_OPERACION 
    ) 
    VALUES 
    ( 
        :NEW.ESSO_ID, 
        :NEW.SOLI_ID, 
        :NEW.TRAM_ID, 
        :NEW.SOLI_REGISTRADOPOR, 
        :NEW.SOLI_FECHACAMBIO, 
        :NEW.SOLI_ACTIVARIMPRESION, 
        :NEW.SOLI_ACTIVO, 
        :NEW.SOLI_PROCESOAUDITORIA, 
        :NEW.SOLI_FECHA, 
        :NEW.PERS_ID, 
        :NEW.SOLI_RADICADO, 
        'I'
    );
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICITUDCARGA 
    AFTER INSERT ON TRAMITE.SOLICITUDCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCARGA(
SOLI_ID,
CAMO_ID,
SOCA_FECHAORIGEN,
SOCA_FECHADESTINO,
SOCA_DIASMOVILIZACION,
SOCA_NUMEROEVASION,
SOCA_FUNCIONARIO,
SOCA_REGISTRADOPOR,
SOCA_FECHACAMBIO,
SOCA_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
SOCA_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.CAMO_ID,
:NEW.SOCA_FECHAORIGEN,
:NEW.SOCA_FECHADESTINO,
:NEW.SOCA_DIASMOVILIZACION,
:NEW.SOCA_NUMEROEVASION,
:NEW.SOCA_FUNCIONARIO,
:NEW.SOCA_REGISTRADOPOR,
:NEW.SOCA_FECHACAMBIO,
:NEW.SOCA_PROCESOAUDITORIA,
:NEW.PERS_ID,
:NEW.VEHI_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLICPAZYSALVO 
    AFTER INSERT ON TRAMITE.SOLICITUDPAZYSALVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDPAZYSALVO(
SOLI_ID,
SOPS_FORMAENTREGA,
SOPS_REGISTRADOPOR,
SOPS_FECHACAMBIO,
SOPS_PROCESOAUDITORIA,
SOPS_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.SOPS_FORMAENTREGA,
:NEW.SOPS_REGISTRADOPOR,
:NEW.SOPS_FECHACAMBIO,
:NEW.SOPS_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_SOLIPAZYSALVOARC 
    AFTER INSERT ON TRAMITE.SOLIPAZYSALVOARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLIPAZYSALVOARCHIVO(
SPSA_ID,
ARCH_ID,
SPSA_REGISTRADOPOR,
SPSA_FECHACAMBIO,
SPSA_PROCESOAUDITORIA,
VEPS_ID,
SPSA_OPERACION
)
VALUES (
:NEW.SPSA_ID,
:NEW.ARCH_ID,
:NEW.SPSA_REGISTRADOPOR,
:NEW.SPSA_FECHACAMBIO,
:NEW.SPSA_PROCESOAUDITORIA,
:NEW.VEPS_ID,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_TIPOCARGA 
    AFTER INSERT ON TRAMITE.TIPOCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPOCARGA(
TICA_ID,
TICA_NOMBRE,
TICA_DESCRIPCION,
TICA_PROCESOAUDITORIA,
TICA_REGISTRADOPOR,
TICA_FECHACAMBIO,
TICA_OPERACION
)
VALUES (
:NEW.TICA_ID,
:NEW.TICA_NOMBRE,
:NEW.TICA_DESCRIPCION,
:NEW.TICA_PROCESOAUDITORIA,
:NEW.TICA_REGISTRADOPOR,
:NEW.TICA_FECHACAMBIO,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_TIPODOCUMENTO 
    AFTER INSERT ON TRAMITE.TIPODOCUMENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPODOCUMENTO(
TIDO_ID,
TIDO_DESCRIPCION,
TIDO_TIPOPERSONA,
TIDO_ABREVIATURA,
TIDO_REGISTRADOPOR,
TIDO_FECHACAMBIO,
TIDO_PROCESOAUDITORIA,
TIDO_OPERACION
)
VALUES (
:NEW.TIDO_ID,
:NEW.TIDO_DESCRIPCION,
:NEW.TIDO_TIPOPERSONA,
:NEW.TIDO_ABREVIATURA,
:NEW.TIDO_REGISTRADOPOR,
:NEW.TIDO_FECHACAMBIO,
:NEW.TIDO_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_TIPOESTSOLIC 
    AFTER INSERT ON TRAMITE.TIPOESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPOESTADOSOLICITUD(
ESSO_ID,
TIPO_ID,
TIES_REGISTRADOPOR,
TIES_FECHACAMBIO,
TIES_PROCESOAUDITORIA,
TIES_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.TIPO_ID,
:NEW.TIES_REGISTRADOPOR,
:NEW.TIES_FECHACAMBIO,
:NEW.TIES_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_TRAMESTSOL 
    AFTER INSERT ON TRAMITE.TRAMITEESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TRAMITEESTADOSOLICITUD(
TRAM_ID,
ESSO_ID,
TRES_REGISTRADOPOR,
TRES_FECHACAMBIO,
TRES_PROCESOAUDITORIA,
TRES_OPERACION
)
VALUES (
:NEW.TRAM_ID,
:NEW.ESSO_ID,
:NEW.TRES_REGISTRADOPOR,
:NEW.TRES_FECHACAMBIO,
:NEW.TRES_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_TRAMITE 
    AFTER INSERT ON TRAMITE.TRAMITE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TRAMITE(
TRAM_ID,
TRAM_NOMBRE,
TRAM_REGISTRADOPOR,
TRAM_FECHACAMBIO,
TRAM_PROCESOAUDITORIA,
TRAM_OPERACION
)
VALUES (
:NEW.TRAM_ID,
:NEW.TRAM_NOMBRE,
:NEW.TRAM_REGISTRADOPOR,
:NEW.TRAM_FECHACAMBIO,
:NEW.TRAM_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_USUARIO 
    AFTER INSERT ON TRAMITE.USUARIO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_USUARIO(
USUA_ID,
PERS_ID,
USUA_DOCUMENTO,
USUA_CONTRASENA,
USUA_REGISTRADOPOR,
USUA_FECHACAMBIO,
USUA_PROCESOAUDITORIA,
TIDO_ID,
USUA_ESTADO,
USUA_OPERACION
)
VALUES (
:NEW.USUA_ID,
:NEW.PERS_ID,
:NEW.USUA_DOCUMENTO,
:NEW.USUA_CONTRASENA,
:NEW.USUA_REGISTRADOPOR,
:NEW.USUA_FECHACAMBIO,
:NEW.USUA_PROCESOAUDITORIA,
:NEW.TIDO_ID,
:NEW.USUA_ESTADO,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_USUARIOTIPO 
    AFTER INSERT ON TRAMITE.USUARIOTIPO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_USUARIOTIPO(
TIPO_ID,
USUA_ID,
USTI_REGISTRADOPOR,
USTI_FECHACAMBIO,
USTI_PROCESOAUDITORIA,
USTI_ESTADO,
USTI_ULTIMOINGRESO,
USTI_OPERACION
)
VALUES (
:NEW.TIPO_ID,
:NEW.USUA_ID,
:NEW.USTI_REGISTRADOPOR,
:NEW.USTI_FECHACAMBIO,
:NEW.USTI_PROCESOAUDITORIA,
:NEW.USTI_ESTADO,
:NEW.USTI_ULTIMOINGRESO,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_VALORDIATRACAR 
    AFTER INSERT ON TRAMITE.VALORDIATRAMITECARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VALORDIATRAMITECARGA(
VDTC_ID,
VIGE_ID,
VDTC_ESTADO,
VDTC_REGISTRADOPOR,
VDTC_FECHACAMBIO,
VDTC_PROCESOAUDITORIA,
VDTC_VALOR,
VDTC_OPERACION
)
VALUES (
:NEW.VDTC_ID,
:NEW.VIGE_ID,
:NEW.VDTC_ESTADO,
:NEW.VDTC_REGISTRADOPOR,
:NEW.VDTC_FECHACAMBIO,
:NEW.VDTC_PROCESOAUDITORIA,
:NEW.VDTC_VALOR,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_VEHICULO 
    AFTER INSERT ON TRAMITE.VEHICULO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VEHICULO(
VEHI_ID,
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
VEHI_REGISTRADOPOR,
VEHI_FECHACAMBIO,
VEHI_PROCESOAUDITORIA,
VEHI_OPERACION
)
VALUES (
:NEW.VEHI_ID,
:NEW.VEHI_MARCA,
:NEW.VEHI_PLACA,
:NEW.VEHI_TIPOVEHICULO,
:NEW.VEHI_REGISTRADOPOR,
:NEW.VEHI_FECHACAMBIO,
:NEW.VEHI_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_VEHICULOPAZYSALVO 
    AFTER INSERT ON TRAMITE.VEHICULOPAZYSALVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VEHICULOPAZYSALVO(
VEPS_ID,
SOLI_ID,
VEPS_REGISTRADOPOR,
VEPS_FECHACAMBIO,
VEPS_PROCESOAUDITORIA,
VEPS_ESTADO,
VEPS_OPERACION
)
VALUES (
:NEW.VEPS_ID,
:NEW.SOLI_ID,
:NEW.VEPS_REGISTRADOPOR,
:NEW.VEPS_FECHACAMBIO,
:NEW.VEPS_PROCESOAUDITORIA,
:NEW.VEPS_ESTADO,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_I_VIGENCIA 
    AFTER INSERT ON TRAMITE.VIGENCIA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VIGENCIA(
VIGE_ID,
VIGE_ANIO,
VIGE_ESTADO,
VIGE_REGISTRADOPOR,
VIGE_FECHACAMBIO,
VIGE_PROCESOAUDITORIA,
VIGE_OPERACION
)
VALUES (
:NEW.VIGE_ID,
:NEW.VIGE_ANIO,
:NEW.VIGE_ESTADO,
:NEW.VIGE_REGISTRADOPOR,
:NEW.VIGE_FECHACAMBIO,
:NEW.VIGE_PROCESOAUDITORIA,
'I');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_ARCHIVO 
    AFTER UPDATE ON TRAMITE.ARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ARCHIVO(
ARCH_ID,
ARCH_EXTENSION,
ARCH_NOMBRE,
ARCH_ARCHIVO,
ARCH_REGISTRADOPOR,
ARCH_FECHACAMBIO,
ARCH_PROCESOAUDITORIA,
ARCH_DESCRIPCION,
ARCH_OPERACION
)
VALUES (
:NEW.ARCH_ID,
:NEW.ARCH_EXTENSION,
:NEW.ARCH_NOMBRE,
:NEW.ARCH_ARCHIVO,
:NEW.ARCH_REGISTRADOPOR,
:NEW.ARCH_FECHACAMBIO,
:NEW.ARCH_PROCESOAUDITORIA,
:NEW.ARCH_DESCRIPCION,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_BANCO 
    AFTER UPDATE ON TRAMITE.BANCO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_BANCO(
BANC_ID,
BANC_NOMBRE,
BANC_REGISTRADOPOR,
BANC_FECHACAMBIO,
BANC_PROCESOAUDITORIA,
BANC_OPERACION
)
VALUES (
:NEW.BANC_ID,
:NEW.BANC_NOMBRE,
:NEW.BANC_REGISTRADOPOR,
:NEW.BANC_FECHACAMBIO,
:NEW.BANC_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_CARGAMOTICA 
    AFTER UPDATE ON TRAMITE.CARGAMOVILIZADATIPOCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CARGAMOVILIZADATIPOCARGA(
TICA_ID,
CAMO_ID,
CMTC_REGISTRADOPOR,
CMTC_FECHACAMBIO,
CMTC_PROCESOAUDITORIA,
CMTC_OPERACION
)
VALUES (
:NEW.TICA_ID,
:NEW.CAMO_ID,
:NEW.CMTC_REGISTRADOPOR,
:NEW.CMTC_FECHACAMBIO,
:NEW.CMTC_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_CARGAMOVILIZADA 
    AFTER UPDATE ON TRAMITE.CARGAMOVILIZADA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CARGAMOVILIZADA(
CAMO_ID,
CAMO_ANCHO,
CAMO_ALTO,
CAMO_LONGITUDSOBRESALIENTE,
CAMO_REGISTRADOPOR,
CAMO_FECHACAMBIO,
CAMO_PROCESOAUDITORIA,
CAMO_OPERACION,
CAMO_PESO
)
VALUES (
:NEW.CAMO_ID,
:NEW.CAMO_ANCHO,
:NEW.CAMO_ALTO,
:NEW.CAMO_LONGITUDSOBRESALIENTE,
:NEW.CAMO_REGISTRADOPOR,
:NEW.CAMO_FECHACAMBIO,
:NEW.CAMO_PROCESOAUDITORIA,
'U',
:NEW.CAMO_PESO);
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_CONSIGNACION 
    AFTER UPDATE ON TRAMITE.CONSIGNACION 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_CONSIGNACION(
CONS_COMPROINGRESO,
CONS_ID,
BANC_ID,
MUNI_ID,
DEPA_ID,
CONS_VALOR,
CONS_FECHA,
CONS_NUMERO,
CONS_REGISTRADOPOR,
CONS_FECHACAMBIO,
CONS_PROCESOAUDITORIA,
SOLI_ID,
CONS_OPERACION
)
VALUES (
:NEW.CONS_COMPROINGRESO,
:NEW.CONS_ID,
:NEW.BANC_ID,
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.CONS_VALOR,
:NEW.CONS_FECHA,
:NEW.CONS_NUMERO,
:NEW.CONS_REGISTRADOPOR,
:NEW.CONS_FECHACAMBIO,
:NEW.CONS_PROCESOAUDITORIA,
:NEW.SOLI_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_DEPARTAMENTO 
    AFTER UPDATE ON TRAMITE.DEPARTAMENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_DEPARTAMENTO(
DEPA_ID,
DEPA_NOMBRE,
DEPA_REGISTRADOPOR,
DEPA_FECHACAMBIO,
DEPA_PROCESOAUDITORIA,
DEPA_OPERACION
)
VALUES (
:NEW.DEPA_ID,
:NEW.DEPA_NOMBRE,
:NEW.DEPA_REGISTRADOPOR,
:NEW.DEPA_FECHACAMBIO,
:NEW.DEPA_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_DIANOHABILCARGA 
    AFTER UPDATE ON TRAMITE.DIANOHABILCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_DIANOHABILCARGA(
DNHC_ID,
DNHC_FECHA,
DNHC_PROCESOAUDITORIA,
DNHC_REGISTRADOPOR,
DNHC_FECHACAMBIO,
DNHC_OPERACION
)
VALUES (
:NEW.DNHC_ID,
:NEW.DNHC_FECHA,
:NEW.DNHC_PROCESOAUDITORIA,
:NEW.DNHC_REGISTRADOPOR,
:NEW.DNHC_FECHACAMBIO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_ESTADOSOLICITUD 
    AFTER UPDATE ON TRAMITE.ESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ESTADOSOLICITUD(
ESSO_ID,
ESSO_DESCRIPCION,
ESSO_TIPOESTADO,
ESSO_REGISTRADOPOR,
ESSO_FECHACAMBIO,
ESSO_PROCESOAUDITORIA,
ESSO_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.ESSO_DESCRIPCION,
:NEW.ESSO_TIPOESTADO,
:NEW.ESSO_REGISTRADOPOR,
:NEW.ESSO_FECHACAMBIO,
:NEW.ESSO_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_ESTADOSOLICSIG 
    AFTER UPDATE ON TRAMITE.ESTADOSOLICITUDSIGUIENTE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_ESTADOSOLICITUDSIGUIENTE(
ESSO_ID_ORIGEN,
ESSO_ID_DESTINO,
ESSI_REGISTRADOPOR,
ESSI_FECHACAMBIO,
ESSI_PROCESOAUDITORIA,
ESSI_OPERACION
)
VALUES (
:NEW.ESSO_ID_ORIGEN,
:NEW.ESSO_ID_DESTINO,
:NEW.ESSI_REGISTRADOPOR,
:NEW.ESSI_FECHACAMBIO,
:NEW.ESSI_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_MUNICIPIO 
    AFTER UPDATE ON TRAMITE.MUNICIPIO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_MUNICIPIO(
MUNI_ID,
DEPA_ID,
MUNI_NOMBRE,
MUNI_REGISTRADOPOR,
MUNI_FECHACAMBIO,
MUNI_PROCESOAUDITORIA,
MUNI_OPERACION
)
VALUES (
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.MUNI_NOMBRE,
:NEW.MUNI_REGISTRADOPOR,
:NEW.MUNI_FECHACAMBIO,
:NEW.MUNI_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PARAMETRIZACION 
    AFTER UPDATE ON TRAMITE.PARAMETRIZACION 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PARAMETRIZACION(
PARA_REDVIAL,
PARA_ANCHO,
PARA_ALTO,
PARA_LONGITUDSOBRESALIENTE,
PARA_LEYENDA,
PARA_URLAPLICATIVO,
PARA_ID,
PARA_PAGOELECTRONICO,
PARA_IMPRESIONRECIBOPAG,
PARA_SOLITRANSPORTECARG,
PARA_SOLIUSOZONACARRETE,
PARA_SOLICIERREVIA,
PARA_SOLIPAZYSALVO,
PARA_REGISTRADOPOR,
PARA_FECHACAMBIO,
PARA_PROCESOAUDITORIA,
PARA_CORREOREMITENTE,
PARA_OPERACION,
PARA_ESFITRAMITECARGA,
PARA_PESO,
PARA_CARGO,
PARA_FUNCIONARIO
)
VALUES (
:NEW.PARA_REDVIAL,
:NEW.PARA_ANCHO,
:NEW.PARA_ALTO,
:NEW.PARA_LONGITUDSOBRESALIENTE,
:NEW.PARA_LEYENDA,
:NEW.PARA_URLAPLICATIVO,
:NEW.PARA_ID,
:NEW.PARA_PAGOELECTRONICO,
:NEW.PARA_IMPRESIONRECIBOPAG,
:NEW.PARA_SOLITRANSPORTECARG,
:NEW.PARA_SOLIUSOZONACARRETE,
:NEW.PARA_SOLICIERREVIA,
:NEW.PARA_SOLIPAZYSALVO,
:NEW.PARA_REGISTRADOPOR,
:NEW.PARA_FECHACAMBIO,
:NEW.PARA_PROCESOAUDITORIA,
:NEW.PARA_CORREOREMITENTE,
'U',
:NEW.PARA_ESFITRAMITECARGA,
:NEW.PARA_PESO,
:NEW.PARA_CARGO,
:NEW.PARA_FUNCIONARIO);
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PERSONA 
    AFTER UPDATE ON TRAMITE.PERSONA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONA(
PERS_ID,
TIDO_ID,
MUNI_ID,
DEPA_ID,
PERS_DOCUMENTOIDENTIDAD,
PERS_DIRECCION,
PERS_TELEFONO,
PERS_CORREOELECTRONICO,
PERS_FAX,
PERS_REGISTRADOPOR,
PERS_FECHACAMBIO,
PERS_PROCESOAUDITORIA,
PERS_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.TIDO_ID,
:NEW.MUNI_ID,
:NEW.DEPA_ID,
:NEW.PERS_DOCUMENTOIDENTIDAD,
:NEW.PERS_DIRECCION,
:NEW.PERS_TELEFONO,
:NEW.PERS_CORREOELECTRONICO,
:NEW.PERS_FAX,
:NEW.PERS_REGISTRADOPOR,
:NEW.PERS_FECHACAMBIO,
:NEW.PERS_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PERSONAJURIDICA 
    AFTER UPDATE ON TRAMITE.PERSONAJURIDICA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAJURIDICA(
PERS_ID,
PERS_IDPERSONANATURAL,
PEJU_RAZONSOCIAL,
PEJU_CODIGOREPRESENTANTE,
PEJU_REGISTRADOPOR,
PEJU_FECHACAMBIO,
PEJU_PROCESOAUDITORIA,
PEJU_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.PERS_IDPERSONANATURAL,
:NEW.PEJU_RAZONSOCIAL,
:NEW.PEJU_CODIGOREPRESENTANTE,
:NEW.PEJU_REGISTRADOPOR,
:NEW.PEJU_FECHACAMBIO,
:NEW.PEJU_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PERSONANATURAL 
    AFTER UPDATE ON TRAMITE.PERSONANATURAL 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONANATURAL(
PERS_ID,
PENA_PRIMERNOMBRE,
PENA_SEGUNDONOMBRE,
PENA_PRIMERAPELLIDO,
PENA_SEGUNDOAPELLIDO,
PENA_REGISTRADOPOR,
PENA_FECHACAMBIO,
PENA_PROCESOAUDITORIA,
PENA_OPERACION
)
VALUES (
:NEW.PERS_ID,
:NEW.PENA_PRIMERNOMBRE,
:NEW.PENA_SEGUNDONOMBRE,
:NEW.PENA_PRIMERAPELLIDO,
:NEW.PENA_SEGUNDOAPELLIDO,
:NEW.PENA_REGISTRADOPOR,
:NEW.PENA_FECHACAMBIO,
:NEW.PENA_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PERSONAREMOLQUE 
    AFTER UPDATE ON TRAMITE.PERSONAREMOLQUE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAREMOLQUE(
REMO_ID,
PERE_FECHACAMBIO,
PERE_REGISTRADOPOR,
PERE_PROCESOAUDITORIA,
PERS_ID,
PERE_OPERACION
)
VALUES (
:NEW.REMO_ID,
:NEW.PERE_FECHACAMBIO,
:NEW.PERE_REGISTRADOPOR,
:NEW.PERE_PROCESOAUDITORIA,
:NEW.PERS_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PERSONAVEHICULO 
    AFTER UPDATE ON TRAMITE.PERSONAVEHICULO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PERSONAVEHICULO(
PEVE_FECHACAMBIO,
PEVE_REGISTRADOPOR,
PEVE_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
PEVE_OPERACION
)
VALUES (
:NEW.PEVE_FECHACAMBIO,
:NEW.PEVE_REGISTRADOPOR,
:NEW.PEVE_PROCESOAUDITORIA,
:NEW.PERS_ID,
:NEW.VEHI_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_PROGEVENTO 
    AFTER UPDATE ON TRAMITE.PROGRAMACIONEVENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_PROGRAMACIONEVENTO(
PREV_ID,
PREV_MUNICIPIOSALIDA,
PREV_MUNICIPIOLLEGADA,
PREV_FECHA,
PREV_HORASALIDA,
PREV_HORALLEGADA,
PREV_LUGARSALIDA,
PREV_LUGARLLEGADA,
PREV_FECHACAMBIO,
PREV_PROCESOAUDITORIA,
PREV_REGISTRADOPOR,
SOLI_ID,
PREV_OPERACION
)
VALUES (
:NEW.PREV_ID,
:NEW.PREV_MUNICIPIOSALIDA,
:NEW.PREV_MUNICIPIOLLEGADA,
:NEW.PREV_FECHA,
:NEW.PREV_HORASALIDA,
:NEW.PREV_HORALLEGADA,
:NEW.PREV_LUGARSALIDA,
:NEW.PREV_LUGARLLEGADA,
:NEW.PREV_FECHACAMBIO,
:NEW.PREV_PROCESOAUDITORIA,
:NEW.PREV_REGISTRADOPOR,
:NEW.SOLI_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_REMOLQUE 
    AFTER UPDATE ON TRAMITE.REMOLQUE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_REMOLQUE(
REMO_ID,
REMO_PLACA,
REMO_REGISTRADOPOR,
REMO_FECHACAMBIO,
REMO_PROCESOAUDITORIA,
REMO_OPERACION
)
VALUES (
:NEW.REMO_ID,
:NEW.REMO_PLACA,
:NEW.REMO_REGISTRADOPOR,
:NEW.REMO_FECHACAMBIO,
:NEW.REMO_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICARGAARCHIVO 
    AFTER UPDATE ON TRAMITE.SOLICITUDCARGAARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCARGAARCHIVO(
SCAR_ID,
ARCH_ID,
SOLI_ID,
SCAR_REGISTRADOPOR,
SCAR_FECHACAMBIO,
SCAR_PROCESOAUDITORIA,
SCAR_OPERACION
)
VALUES (
:NEW.SCAR_ID,
:NEW.ARCH_ID,
:NEW.SOLI_ID,
:NEW.SCAR_REGISTRADOPOR,
:NEW.SCAR_FECHACAMBIO,
:NEW.SCAR_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICCIERREVIA 
    AFTER UPDATE ON TRAMITE.SOLICITUDCIERREVIA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCIERREVIA(
SOLI_ID,
SOCV_NOMBREEVENTO,
SOCV_AVALADOPOR,
SOCV_RECORRIDOPROGRAMADO,
SOCV_REGISTRADOPOR,
SOCV_FECHACAMBIO,
SOCV_PROCESOAUDITORIA,
SOCV_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.SOCV_NOMBREEVENTO,
:NEW.SOCV_AVALADOPOR,
:NEW.SOCV_RECORRIDOPROGRAMADO,
:NEW.SOCV_REGISTRADOPOR,
:NEW.SOCV_FECHACAMBIO,
:NEW.SOCV_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICIERREVIAAR 
    AFTER UPDATE ON TRAMITE.SOLICITUDCIERREVIAARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCIERREVIAARCHIVO(
SCVA_ID,
ARCH_ID,
SOLI_ID,
SCVA_REGISTRADOPOR,
SCVA_FECHACAMBIO,
SCVA_PROCESOAUDITORIA,
SCVA_OPERACION
)
VALUES (
:NEW.SCVA_ID,
:NEW.ARCH_ID,
:NEW.SOLI_ID,
:NEW.SCVA_REGISTRADOPOR,
:NEW.SCVA_FECHACAMBIO,
:NEW.SCVA_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICITUD 
    AFTER UPDATE ON TRAMITE.SOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUD(
ESSO_ID,
SOLI_ID,
TRAM_ID,
SOLI_REGISTRADOPOR,
SOLI_FECHACAMBIO,
SOLI_ACTIVARIMPRESION,
SOLI_ACTIVO,
SOLI_PROCESOAUDITORIA,
SOLI_FECHA,
PERS_ID,
SOLI_RADICADO,
SOLI_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.SOLI_ID,
:NEW.TRAM_ID,
:NEW.SOLI_REGISTRADOPOR,
:NEW.SOLI_FECHACAMBIO,
:NEW.SOLI_ACTIVARIMPRESION,
:NEW.SOLI_ACTIVO,
:NEW.SOLI_PROCESOAUDITORIA,
:NEW.SOLI_FECHA,
:NEW.PERS_ID,
:NEW.SOLI_RADICADO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICITUDCARGA 
    AFTER UPDATE ON TRAMITE.SOLICITUDCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDCARGA(
SOLI_ID,
CAMO_ID,
SOCA_FECHAORIGEN,
SOCA_FECHADESTINO,
SOCA_DIASMOVILIZACION,
SOCA_NUMEROEVASION,
SOCA_FUNCIONARIO,
SOCA_REGISTRADOPOR,
SOCA_FECHACAMBIO,
SOCA_PROCESOAUDITORIA,
PERS_ID,
VEHI_ID,
SOCA_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.CAMO_ID,
:NEW.SOCA_FECHAORIGEN,
:NEW.SOCA_FECHADESTINO,
:NEW.SOCA_DIASMOVILIZACION,
:NEW.SOCA_NUMEROEVASION,
:NEW.SOCA_FUNCIONARIO,
:NEW.SOCA_REGISTRADOPOR,
:NEW.SOCA_FECHACAMBIO,
:NEW.SOCA_PROCESOAUDITORIA,
:NEW.PERS_ID,
:NEW.VEHI_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLICPAZYSALVO 
    AFTER UPDATE ON TRAMITE.SOLICITUDPAZYSALVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLICITUDPAZYSALVO(
SOLI_ID,
SOPS_FORMAENTREGA,
SOPS_REGISTRADOPOR,
SOPS_FECHACAMBIO,
SOPS_PROCESOAUDITORIA,
SOPS_OPERACION
)
VALUES (
:NEW.SOLI_ID,
:NEW.SOPS_FORMAENTREGA,
:NEW.SOPS_REGISTRADOPOR,
:NEW.SOPS_FECHACAMBIO,
:NEW.SOPS_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_SOLIPAZYSALVOARC 
    AFTER UPDATE ON TRAMITE.SOLIPAZYSALVOARCHIVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_SOLIPAZYSALVOARCHIVO(
SPSA_ID,
ARCH_ID,
SPSA_REGISTRADOPOR,
SPSA_FECHACAMBIO,
SPSA_PROCESOAUDITORIA,
VEPS_ID,
SPSA_OPERACION
)
VALUES (
:NEW.SPSA_ID,
:NEW.ARCH_ID,
:NEW.SPSA_REGISTRADOPOR,
:NEW.SPSA_FECHACAMBIO,
:NEW.SPSA_PROCESOAUDITORIA,
:NEW.VEPS_ID,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_TIPOCARGA 
    AFTER UPDATE ON TRAMITE.TIPOCARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPOCARGA(
TICA_ID,
TICA_NOMBRE,
TICA_DESCRIPCION,
TICA_PROCESOAUDITORIA,
TICA_REGISTRADOPOR,
TICA_FECHACAMBIO,
TICA_OPERACION
)
VALUES (
:NEW.TICA_ID,
:NEW.TICA_NOMBRE,
:NEW.TICA_DESCRIPCION,
:NEW.TICA_PROCESOAUDITORIA,
:NEW.TICA_REGISTRADOPOR,
:NEW.TICA_FECHACAMBIO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_TIPODOCUMENTO 
    AFTER UPDATE ON TRAMITE.TIPODOCUMENTO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPODOCUMENTO(
TIDO_ID,
TIDO_DESCRIPCION,
TIDO_TIPOPERSONA,
TIDO_ABREVIATURA,
TIDO_REGISTRADOPOR,
TIDO_FECHACAMBIO,
TIDO_PROCESOAUDITORIA,
TIDO_OPERACION
)
VALUES (
:NEW.TIDO_ID,
:NEW.TIDO_DESCRIPCION,
:NEW.TIDO_TIPOPERSONA,
:NEW.TIDO_ABREVIATURA,
:NEW.TIDO_REGISTRADOPOR,
:NEW.TIDO_FECHACAMBIO,
:NEW.TIDO_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_TIPOESTSOLIC 
    AFTER UPDATE ON TRAMITE.TIPOESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TIPOESTADOSOLICITUD(
ESSO_ID,
TIPO_ID,
TIES_REGISTRADOPOR,
TIES_FECHACAMBIO,
TIES_PROCESOAUDITORIA,
TIES_OPERACION
)
VALUES (
:NEW.ESSO_ID,
:NEW.TIPO_ID,
:NEW.TIES_REGISTRADOPOR,
:NEW.TIES_FECHACAMBIO,
:NEW.TIES_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_TRAMESTSOL 
    AFTER UPDATE ON TRAMITE.TRAMITEESTADOSOLICITUD 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TRAMITEESTADOSOLICITUD(
TRAM_ID,
ESSO_ID,
TRES_REGISTRADOPOR,
TRES_FECHACAMBIO,
TRES_PROCESOAUDITORIA,
TRES_OPERACION
)
VALUES (
:NEW.TRAM_ID,
:NEW.ESSO_ID,
:NEW.TRES_REGISTRADOPOR,
:NEW.TRES_FECHACAMBIO,
:NEW.TRES_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_TRAMITE 
    AFTER UPDATE ON TRAMITE.TRAMITE 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_TRAMITE(
TRAM_ID,
TRAM_NOMBRE,
TRAM_REGISTRADOPOR,
TRAM_FECHACAMBIO,
TRAM_PROCESOAUDITORIA,
TRAM_OPERACION
)
VALUES (
:NEW.TRAM_ID,
:NEW.TRAM_NOMBRE,
:NEW.TRAM_REGISTRADOPOR,
:NEW.TRAM_FECHACAMBIO,
:NEW.TRAM_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_USUARIO 
    AFTER UPDATE ON TRAMITE.USUARIO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_USUARIO(
USUA_ID,
PERS_ID,
USUA_DOCUMENTO,
USUA_CONTRASENA,
USUA_REGISTRADOPOR,
USUA_FECHACAMBIO,
USUA_PROCESOAUDITORIA,
TIDO_ID,
USUA_ESTADO,
USUA_OPERACION
)
VALUES (
:NEW.USUA_ID,
:NEW.PERS_ID,
:NEW.USUA_DOCUMENTO,
:NEW.USUA_CONTRASENA,
:NEW.USUA_REGISTRADOPOR,
:NEW.USUA_FECHACAMBIO,
:NEW.USUA_PROCESOAUDITORIA,
:NEW.TIDO_ID,
:NEW.USUA_ESTADO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_USUARIOTIPO 
    AFTER UPDATE ON TRAMITE.USUARIOTIPO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_USUARIOTIPO(
TIPO_ID,
USUA_ID,
USTI_REGISTRADOPOR,
USTI_FECHACAMBIO,
USTI_PROCESOAUDITORIA,
USTI_ESTADO,
USTI_ULTIMOINGRESO,
USTI_OPERACION
)
VALUES (
:NEW.TIPO_ID,
:NEW.USUA_ID,
:NEW.USTI_REGISTRADOPOR,
:NEW.USTI_FECHACAMBIO,
:NEW.USTI_PROCESOAUDITORIA,
:NEW.USTI_ESTADO,
:NEW.USTI_ULTIMOINGRESO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_VALORDIATRACAR 
    AFTER UPDATE ON TRAMITE.VALORDIATRAMITECARGA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VALORDIATRAMITECARGA(
VDTC_ID,
VIGE_ID,
VDTC_ESTADO,
VDTC_REGISTRADOPOR,
VDTC_FECHACAMBIO,
VDTC_PROCESOAUDITORIA,
VDTC_VALOR,
VDTC_OPERACION
)
VALUES (
:NEW.VDTC_ID,
:NEW.VIGE_ID,
:NEW.VDTC_ESTADO,
:NEW.VDTC_REGISTRADOPOR,
:NEW.VDTC_FECHACAMBIO,
:NEW.VDTC_PROCESOAUDITORIA,
:NEW.VDTC_VALOR,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_VEHICULO 
    AFTER UPDATE ON TRAMITE.VEHICULO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VEHICULO(
VEHI_ID,
VEHI_MARCA,
VEHI_PLACA,
VEHI_TIPOVEHICULO,
VEHI_REGISTRADOPOR,
VEHI_FECHACAMBIO,
VEHI_PROCESOAUDITORIA,
VEHI_OPERACION
)
VALUES (
:NEW.VEHI_ID,
:NEW.VEHI_MARCA,
:NEW.VEHI_PLACA,
:NEW.VEHI_TIPOVEHICULO,
:NEW.VEHI_REGISTRADOPOR,
:NEW.VEHI_FECHACAMBIO,
:NEW.VEHI_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_VEHICULOPAZYSALVO 
    AFTER UPDATE ON TRAMITE.VEHICULOPAZYSALVO 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VEHICULOPAZYSALVO(
VEPS_ID,
SOLI_ID,
VEPS_REGISTRADOPOR,
VEPS_FECHACAMBIO,
VEPS_PROCESOAUDITORIA,
VEPS_ESTADO,
VEPS_OPERACION
)
VALUES (
:NEW.VEPS_ID,
:NEW.SOLI_ID,
:NEW.VEPS_REGISTRADOPOR,
:NEW.VEPS_FECHACAMBIO,
:NEW.VEPS_PROCESOAUDITORIA,
:NEW.VEPS_ESTADO,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.TR_TRAMITE_U_VIGENCIA 
    AFTER UPDATE ON TRAMITE.VIGENCIA 
    FOR EACH ROW 
BEGIN

INSERT INTO TRAMITE.AUD_VIGENCIA(
VIGE_ID,
VIGE_ANIO,
VIGE_ESTADO,
VIGE_REGISTRADOPOR,
VIGE_FECHACAMBIO,
VIGE_PROCESOAUDITORIA,
VIGE_OPERACION
)
VALUES (
:NEW.VIGE_ID,
:NEW.VIGE_ANIO,
:NEW.VIGE_ESTADO,
:NEW.VIGE_REGISTRADOPOR,
:NEW.VIGE_FECHACAMBIO,
:NEW.VIGE_PROCESOAUDITORIA,
'U');
END; 
/

CREATE OR REPLACE TRIGGER TRAMITE.VEHICULO_ARCHIVO_TRG 
    BEFORE INSERT ON TRAMITE.VEHICULO_ARCHIVO 
    FOR EACH ROW 
DECLARE
  N NUMBER;
BEGIN
-- For Toad:  Highlight column VEAR_ID
  Select VEHICULO_ARCHIVO_SEQ.nextval into n from dual;
  :new.VEAR_ID := N;
END VEHICULO_ARCHIVO_TRG; 
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                           125
-- CREATE INDEX                            84
-- ALTER TABLE                            159
-- CREATE VIEW                              6
-- ALTER VIEW                               0
-- CREATE PACKAGE                           1
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                        89
-- CREATE FUNCTION                          2
-- CREATE TRIGGER                         116
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              2
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        2
-- CREATE USER                              1
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 2
