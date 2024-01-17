---------------------------------------------------------------------------
----------------------- The first package specification -------------------
---------------------------------------------------------------------------
CREATE OR replace PACKAGE traveler_assistance_package
AS
  -- Definition of a record for the first procedure
  TYPE country_info IS RECORD (
    country_name countries.country_name %TYPE,
    location countries.location %TYPE,
    capitol countries.capitol %TYPE,
    population countries.population %TYPE,
    airports countries.airports %TYPE,
    climate countries.climate %TYPE );
  -- Definition of a record for the second procedure
  TYPE country_reg_curr_info IS RECORD (
    country_name countries.country_name %TYPE,
    region regions.region_name %TYPE,
    currency currencies.currency_name %TYPE );
  -- Definition of a record for the array of records
  TYPE country_lang_info IS RECORD (
    country_name countries.country_name %TYPE,
    language_name languages.language_name %TYPE,
    official_language spoken_languages.official %TYPE );
  -- Defining an array type for the third and fourth procedure
  TYPE country_reg_curr_arr
    IS TABLE OF COUNTRY_REG_CURR_INFO INDEX BY PLS_INTEGER;
  -- Defining an array type for the fifth and sixth procedure
  TYPE country_lang_arr
    IS TABLE OF COUNTRY_LANG_INFO INDEX BY PLS_INTEGER;
  -- Declaring the procedures
  PROCEDURE country_demographics (
    in_country_name VARCHAR2);
  PROCEDURE find_region_and_currency(
    in_country_name      IN VARCHAR2,
    out_country_reg_curr OUT COUNTRY_REG_CURR_INFO );
  PROCEDURE countries_in_region(
    in_region_name   IN VARCHAR2,
    out_country_info OUT COUNTRY_REG_CURR_ARR );
  PROCEDURE print_region_array(
    in_country_reg_curr_arr COUNTRY_REG_CURR_ARR );
  PROCEDURE country_languages(
    in_country_name   IN VARCHAR2,
    out_country_langs OUT COUNTRY_LANG_ARR );
  PROCEDURE print_language_array(
    country_languages COUNTRY_LANG_ARR);
END traveler_assistance_package;

/
---------------------------------------------------------------------------
--------------------- The first package implementation --------------------
---------------------------------------------------------------------------
CREATE OR replace PACKAGE BODY traveler_assistance_package
AS
  -- Procedure no. 1
  PROCEDURE Country_demographics(in_country_name VARCHAR2)
  IS
    out_country_info COUNTRY_INFO;
  BEGIN
      -- The record is populated with the data from select statement
      SELECT country_name,
             location,
             capitol,
             population,
             airports,
             climate
      INTO   out_country_info
      FROM   countries
      -- This way the search is not case sensitive
      WHERE  Lower(country_name) = Lower(in_country_name);

      -- For testing purposes
      dbms_output.Put_line(out_country_info.country_name
                           || ', '
                           || out_country_info.location
                           || ', '
                           || out_country_info.capitol
                           || ', '
                           || out_country_info.population
                           || ', '
                           || out_country_info.airports
                           || ', '
                           || out_country_info.climate);

  -- Exception in case the given country is not found in the database
  EXCEPTION
    WHEN no_data_found THEN
               Raise_application_error(-20001, in_country_name
                                               || ' not found in the database.')
               ;
  END;
  -- Procedure no. 2
  PROCEDURE Find_region_and_currency(in_country_name      IN VARCHAR2,
  out_country_reg_curr OUT COUNTRY_REG_CURR_INFO)
  IS
  -- The record is populated with the data from select statement
  BEGIN
      SELECT countries.country_name,
             regions.region_name,
             currencies.currency_name
      INTO   out_country_reg_curr
      FROM   countries countries,
             regions regions,
             currencies currencies
      -- Where the region id and the currency code match the ones in the countries table
      WHERE  Lower(countries.country_name) = Lower(in_country_name)
             AND countries.region_id = regions.region_id
             AND countries.currency_code = currencies.currency_code;

      -- For testing purposes

      dbms_output.Put_line(out_country_reg_curr.country_name
                           || ', '
                           || out_country_reg_curr.region
                           || ', '
                           || out_country_reg_curr.currency);

  EXCEPTION
    WHEN no_data_found THEN
               Raise_application_error(-20001, in_country_name
                                               || ' not found in the database.')
               ;
  END;
  -- Procedure no. 3
  PROCEDURE Countries_in_region(in_region_name   IN VARCHAR2,
                                out_country_info OUT COUNTRY_REG_CURR_ARR)
  IS
    -- The cursor is a query that returns a result set, which is a collection of rows
    CURSOR countries_region IS
      SELECT c.country_name,
             r.region_name,
             curr.currency_name
      FROM   countries c,
             regions r,
             currencies curr
      WHERE  c.region_id = r.region_id
             AND c.currency_code = curr.currency_code
             AND Lower(r.region_name) = Lower(in_region_name);
    i PLS_INTEGER := 1;
  -- The result set is iterated over and the rows are inserted into the associative array
  BEGIN
      FOR country IN countries_region LOOP
          Out_country_info(i) := country;

          i := i + 1;
      END LOOP;
  EXCEPTION
    WHEN no_data_found THEN
               Raise_application_error(-20001, in_region_name
                                               || ' not found in the database.')
               ;
  END;
  -- Procedure no. 4
  PROCEDURE Print_region_array(in_country_reg_curr_arr COUNTRY_REG_CURR_ARR)
  IS
  BEGIN
      -- The associative array is iterated over and the rows are printed
      FOR i IN in_country_reg_curr_arr.first..in_country_reg_curr_arr.last LOOP
          dbms_output.Put_line(In_country_reg_curr_arr(i).country_name
                               || ', '
                               || In_country_reg_curr_arr(i).region
                               || ', '
                               || In_country_reg_curr_arr(i).currency);
      END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
               -- SQLERRM returns error message associated with the lastest executet statement
               dbms_output.Put_line('An unexpected error occurred: '
                                    || SQLERRM);
  END;
  -- Procedure no. 5
  PROCEDURE Country_languages(in_country_name   IN VARCHAR2,
                              out_country_langs OUT COUNTRY_LANG_ARR)
  IS
    -- Using a cursor, fetch data from the database
    CURSOR country_languages_cursor IS
      SELECT countries.country_name,
             languages.language_name,
             spokenlang.official
      FROM   countries countries,
             languages languages,
             spoken_languages spokenlang
      WHERE  Lower(countries.country_name) = Lower(in_country_name)
             AND countries.country_id = spokenlang.country_id
             AND spokenlang.language_id = languages.language_id;
    i PLS_INTEGER := 1;
  BEGIN
      FOR country_language IN country_languages_cursor LOOP
          -- Assign the cursor data to an index of the array
          Out_country_langs(i) := country_language;
          -- For testing purposes print the data
          dbms_output.Put_line(Out_country_langs(i).country_name
                               || ', '
                               || Out_country_langs(i).language_name
                               || ', '
                               || Out_country_langs(i).official_language);

          i := i + 1;
      END LOOP;
  EXCEPTION
    WHEN no_data_found THEN
               Raise_application_error(-20001, in_country_name
                                               || ' not found in the database.')
               ;
  END;
  -- Procedure no. 6
  PROCEDURE Print_language_array(country_languages COUNTRY_LANG_ARR)
  IS
  BEGIN
      FOR i IN country_languages.first..country_languages.last LOOP
          dbms_output.Put_line(Country_languages(i).country_name
                               || ', '
                               || Country_languages(i).language_name
                               || ', '
                               || Country_languages(i).official_language);
      END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
               -- SQLERRM returns error message associated with the lastest executet statement
               dbms_output.Put_line('An unexpected error occurred: '
                                    || SQLERRM);
  END;
END;

/
---------------------------------------------------------------------------
---------------------- The second package specification -------------------
---------------------------------------------------------------------------
CREATE OR replace PACKAGE traveler_admin_package
AS
  -- Definition of a record for the seventh procedure
  TYPE object_info IS RECORD(
    name user_dependencies.name%TYPE,
    TYPE user_dependencies.TYPE%TYPE,
    referenced_name user_dependencies.referenced_name%TYPE,
    referenced_type user_dependencies.referenced_type%TYPE );
  -- Defining an array type for the eighth and ninth procedure
  TYPE object_arr
    IS TABLE OF OBJECT_INFO INDEX BY PLS_INTEGER;
  PROCEDURE display_disabled_triggers;
  FUNCTION All_dependent_objects(
    object_name VARCHAR2)
  RETURN OBJECT_ARR;
  PROCEDURE print_dependent_objects(
    objects IN OBJECT_ARR);
END traveler_admin_package;

/
---------------------------------------------------------------------------
--------------------- The second package implementation -------------------
---------------------------------------------------------------------------
CREATE OR replace PACKAGE BODY traveler_admin_package
AS
  -- Procedure no. 7
  PROCEDURE Display_disabled_triggers
  IS
  BEGIN
      FOR trigger_rec IN (SELECT trigger_name,
                                 trigger_type,
                                 status
                          FROM   user_triggers
                          WHERE  status = 'DISABLED') LOOP
          dbms_output.Put_line(trigger_rec.trigger_name
                               || ' '
                               || trigger_rec.trigger_type
                               || ' '
                               || trigger_rec.status);
      END LOOP;

      -- If no data found db.m_output will print the message
      IF SQL%NOTFOUND THEN
        Raise_application_error(-20001, 'No data found');
      END IF;
  END;
  -- Procedure no. 8
  FUNCTION All_dependent_objects(object_name VARCHAR2)
  RETURN OBJECT_ARR
  IS
    CURSOR object_cur IS
      SELECT name,
             TYPE,
             referenced_name,
             referenced_type
      FROM   user_dependencies
      WHERE  Lower(referenced_name) = Lower(object_name);
    v_objects OBJECT_ARR;
    i         PLS_INTEGER := 1;
  BEGIN
      FOR v_object IN object_cur LOOP
          V_objects(i) := v_object;

          i := i + 1;
      END LOOP;

      IF v_objects IS NULL THEN
        Raise_application_error(-20001, 'No data found for '
                                        || object_name);
      END IF;

      RETURN v_objects;
  EXCEPTION
    WHEN OTHERS THEN
               dbms_output.Put_line('An unexpected error occurred: '
                                    || SQLERRM);
  END;
  -- -- Procedure no. 9
  PROCEDURE print_dependent_objects(objects IN OBJECT_ARR)
  IS
  BEGIN
      FOR i IN objects.first .. objects.last LOOP
        DBMS_OUTPUT.PUT_LINE(
          'Name: ' || objects(i).name ||
          ', Type: ' || objects(i).TYPE ||
          ', Referenced Name: ' || objects(i).referenced_name ||
          ', Referenced Type: ' || objects(i).referenced_type
        );
      END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
               dbms_output.Put_line('An unexpected error occurred: '
                                    || SQLERRM);
  END;
END;

/ 