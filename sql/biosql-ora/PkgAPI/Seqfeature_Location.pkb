--
-- API Package Body for Seqfeature_Location.
--
-- Scaffold auto-generated by gen-api.pl (H.Lapp, 2002).
--
-- $Id: Seqfeature_Location.pkb,v 1.1.1.1 2002-08-13 19:51:10 lapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
--
-- You may distribute this module under the same terms as Perl.
-- Refer to the Perl Artistic License (see the license accompanying this
-- software package, or see http://www.perl.com/language/misc/Artistic.html)
-- for the terms under which you may use, modify, and redistribute this module.
-- 
-- THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
-- MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--

CREATE OR REPLACE
PACKAGE BODY Loc IS

CURSOR Loc_c (
		Loc_FEA_OID	IN SG_SEQFEATURE_LOCATION.FEA_OID%TYPE,
		Loc_RANK	IN SG_SEQFEATURE_LOCATION.RANK%TYPE)
RETURN SG_SEQFEATURE_LOCATION%ROWTYPE IS
	SELECT t.* FROM SG_SEQFEATURE_LOCATION t
	WHERE
		t.FEA_OID = Loc_FEA_OID
	AND	t.RANK = Loc_RANK
	;

FUNCTION get_oid(
		Loc_OID	IN SG_SEQFEATURE_LOCATION.OID%TYPE DEFAULT NULL,
		Loc_START_POS	IN SG_SEQFEATURE_LOCATION.START_POS%TYPE DEFAULT NULL,
		Loc_END_POS	IN SG_SEQFEATURE_LOCATION.END_POS%TYPE DEFAULT NULL,
		Loc_STRAND	IN SG_SEQFEATURE_LOCATION.STRAND%TYPE DEFAULT NULL,
		Loc_RANK	IN SG_SEQFEATURE_LOCATION.RANK%TYPE,
		FEA_OID	IN SG_SEQFEATURE_LOCATION.FEA_OID%TYPE,
		ENT_OID	IN SG_SEQFEATURE_LOCATION.ENT_OID%TYPE DEFAULT NULL,
		Ent_ACCESSION	IN SG_BIOENTRY.ACCESSION%TYPE DEFAULT NULL,
		Ent_VERSION	IN SG_BIOENTRY.VERSION%TYPE DEFAULT NULL,
		DB_OID		IN SG_BIOENTRY.DB_OID%TYPE DEFAULT NULL,
		Ent_IDENTIFIER	IN SG_BIOENTRY.IDENTIFIER%TYPE DEFAULT NULL,
		Fea_ENT_OID	IN SG_SEQFEATURE.ENT_OID%TYPE DEFAULT NULL,
		Fea_RANK	IN SG_SEQFEATURE.RANK%TYPE DEFAULT NULL,
		Fea_ONT_OID	IN SG_SEQFEATURE.ONT_OID%TYPE DEFAULT NULL,
		do_DML		IN NUMBER DEFAULT BSStd.DML_NO)
RETURN SG_SEQFEATURE_LOCATION.OID%TYPE
IS
	pk	SG_SEQFEATURE_LOCATION.OID%TYPE DEFAULT NULL;
	Loc_row Loc_c%ROWTYPE;
	ENT_OID_	SG_BIOENTRY.OID%TYPE DEFAULT ENT_OID;
	FEA_OID_	SG_SEQFEATURE.OID%TYPE DEFAULT FEA_OID;
BEGIN
	-- initialize
	IF (do_DML > BSStd.DML_NO) THEN
		pk := Loc_OID;
	END IF;
	-- look up SG_SEQFEATURE
	IF (FEA_OID_ IS NULL) THEN
		FEA_OID_ := Fea.get_oid(
				ENT_OID => Fea_ENT_OID,
				Fea_RANK => Fea_RANK,
				ONT_OID => Fea_ONT_OID);
	END IF;
	-- look up
	IF pk IS NULL THEN
		FOR Loc_row IN Loc_c(FEA_OID_, Loc_RANK) LOOP
		        pk := Loc_row.OID;
		END LOOP;
	END IF;
	-- insert/update if requested
	IF (pk IS NULL) AND 
	   ((do_DML = BSStd.DML_I) OR (do_DML = BSStd.DML_UI)) THEN
	    	-- look up foreign keys if not provided:
		-- look up SG_BIOENTRY
		IF (Ent_Accession IS NOT NULL) OR 
		   (Ent_Identifier IS NOT NULL) THEN
			IF (ENT_OID_ IS NULL)  THEN
			   ENT_OID_ := Ent.get_oid(
				Ent_ACCESSION => Ent_ACCESSION,
				Ent_VERSION => Ent_VERSION,
				DB_OID => DB_OID,
				Ent_IDENTIFIER => Ent_IDENTIFIER);
			END IF;
			IF (ENT_OID_ IS NULL) THEN
			   raise_application_error(-20101,
				'failed to look up Ent <' || Ent_ACCESSION || '|' || Ent_VERSION || '|' || DB_OID || '|' || Ent_IDENTIFIER || '>');
			END IF;
		END IF;
		-- look up SG_SEQFEATURE successful?
		IF (FEA_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Fea <' || Fea_ENT_OID || '|' || Fea_RANK || '|' || Fea_ONT_OID || '>');
		END IF;
	    	-- insert the record and obtain the primary key
	    	pk := do_insert(
		        START_POS => Loc_START_POS,
			END_POS => Loc_END_POS,
			STRAND => Loc_STRAND,
			RANK => Loc_RANK,
			FEA_OID => FEA_OID_,
			ENT_OID => ENT_OID_);
	ELSIF (do_DML = BSStd.DML_U) OR (do_DML = BSStd.DML_UI) THEN
	        -- update the record (note that not provided FKs will not
		-- be changed nor looked up)
		do_update(
			Loc_OID	=> pk,
		        Loc_START_POS => Loc_START_POS,
			Loc_END_POS => Loc_END_POS,
			Loc_STRAND => Loc_STRAND,
			Loc_RANK => Loc_RANK,
			Loc_FEA_OID => FEA_OID_,
			Loc_ENT_OID => ENT_OID_);
	END IF;
	-- return the primary key
	RETURN pk;
END;

FUNCTION do_insert(
		START_POS	IN SG_SEQFEATURE_LOCATION.START_POS%TYPE,
		END_POS	IN SG_SEQFEATURE_LOCATION.END_POS%TYPE,
		STRAND	IN SG_SEQFEATURE_LOCATION.STRAND%TYPE,
		RANK	IN SG_SEQFEATURE_LOCATION.RANK%TYPE,
		FEA_OID	IN SG_SEQFEATURE_LOCATION.FEA_OID%TYPE,
		ENT_OID	IN SG_SEQFEATURE_LOCATION.ENT_OID%TYPE)
RETURN SG_SEQFEATURE_LOCATION.OID%TYPE 
IS
	pk	SG_SEQFEATURE_LOCATION.OID%TYPE;
BEGIN
	-- pre-generate the primary key value
	SELECT SG_Sequence.nextval INTO pk FROM DUAL;
	-- insert the record
	INSERT INTO SG_SEQFEATURE_LOCATION (
		OID,
		START_POS,
		END_POS,
		STRAND,
		RANK,
		FEA_OID,
		ENT_OID)
	VALUES (pk,
		START_POS,
		END_POS,
		STRAND,
		RANK,
		FEA_OID,
		ENT_OID)
	;
	-- return the new pk value
	RETURN pk;
END;

PROCEDURE do_update(
		Loc_OID	IN SG_SEQFEATURE_LOCATION.OID%TYPE,
		Loc_START_POS	IN SG_SEQFEATURE_LOCATION.START_POS%TYPE,
		Loc_END_POS	IN SG_SEQFEATURE_LOCATION.END_POS%TYPE,
		Loc_STRAND	IN SG_SEQFEATURE_LOCATION.STRAND%TYPE,
		Loc_RANK	IN SG_SEQFEATURE_LOCATION.RANK%TYPE,
		Loc_FEA_OID	IN SG_SEQFEATURE_LOCATION.FEA_OID%TYPE,
		Loc_ENT_OID	IN SG_SEQFEATURE_LOCATION.ENT_OID%TYPE)
IS
BEGIN
	-- update the record (and leave attributes passed as NULL untouched)
	UPDATE SG_SEQFEATURE_LOCATION
	SET
		START_POS = NVL(Loc_START_POS, START_POS),
		END_POS = NVL(Loc_END_POS, END_POS),
		STRAND = NVL(Loc_STRAND, STRAND),
		RANK = NVL(Loc_RANK, RANK),
		FEA_OID = NVL(Loc_FEA_OID, FEA_OID),
		ENT_OID = NVL(Loc_ENT_OID, ENT_OID)
	WHERE OID = Loc_OID
	;
END;

END Loc;
/

