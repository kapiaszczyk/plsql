---------------------------------------------------------------------------
----------------------- The first package specification -------------------
---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE traveler_assistance_package AS 

    -- Definition of a record for the first procedure
    TYPE country_info IS RECORD (
        country_name countries.country_name %TYPE,
        location countries.location %TYPE,
        capitol countries.capitol %TYPE,
        population countries.population %TYPE,
        airports countries.airports %TYPE,
        climate countries.climate %TYPE
    );

    -- Definition of a record for the second procedure
    TYPE country_reg_curr IS RECORD (
        country_name countries.country_name %TYPE,
        region regions.region_name %TYPE,
        currency currencies.currency_name %TYPE
    );

    -- Definition of a record for the array of records
    TYPE country_language_info IS RECORD (
        country_name countries.country_name %TYPE,
        language_name languages.language_name %TYPE,
        official_language spoken_languages.official %TYPE
    );

    -- Defining an array type for the third procedure, associative array of records 
    TYPE country_reg_curr_table IS TABLE OF country_reg_curr INDEX BY PLS_INTEGER;

    -- Defining a record type for the fifth procedure
    TYPE country_languages_arr IS TABLE OF country_language_info INDEX BY PLS_INTEGER;

    -- Declaring the procedures
    PROCEDURE country_demographics (in_country_name VARCHAR2);
    PROCEDURE find_region_and_currency(
        in_country_name IN VARCHAR2,
        out_country_reg_curr OUT country_reg_curr
    );
    PROCEDURE countries_in_region(
        in_region_name IN VARCHAR2,
        out_country_info OUT country_reg_curr_table
    );
    PROCEDURE print_region_array(
        in_country_reg_curr_table country_reg_curr_table
    );
    PROCEDURE country_languages(
        in_country_name IN VARCHAR2,
        out_country_langs OUT country_languages_arr
    );
    PROCEDURE print_language_array(country_languages country_languages_arr);
END traveler_assistance_package;
/ 

---------------------------------------------------------------------------
--------------------- The first package implementation --------------------
---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY traveler_assistance_package AS 

    -- Procedure no. 1
    PROCEDURE country_demographics(
        in_country_name VARCHAR2
        ) IS out_country_info country_info;
        BEGIN
            -- The record is populated with the data from select statement
            SELECT 
                country_name, 
                location, 
                capitol,
                population,
                airports,
                climate 
            INTO out_country_info
            FROM countries
            -- This way the search is not case sensitive
            WHERE 
                Lower(country_name) = Lower(in_country_name);
            -- Exception in case the given country is not found in the database
            EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(
                -20001,
                in_country_name || ' not found in the database.'
            );
    END;

    -- Procedure no. 2
    PROCEDURE find_region_and_currency(
        in_country_name IN VARCHAR2,
        out_country_reg_curr OUT country_reg_curr
        ) IS 
        -- The record is populated with the data from select statement
        BEGIN
        SELECT 
            countries.country_name,
            regions.region_name,
            currencies.currency_name 
        INTO out_country_reg_curr
        FROM COUNTRIES countries,
            REGIONS regions,
            CURRENCIES currencies
        -- Where the region id and the currency code match the ones in the countries table
        WHERE 
            Lower(countries.country_name) = Lower(in_country_name)
            AND countries.REGION_ID = regions.REGION_ID
            AND countries.CURRENCY_CODE = currencies.CURRENCY_CODE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(
            -20001,
            in_country_name || ' not found in the database.'
        );
    END;

    -- Procedure no. 3
    PROCEDURE countries_in_region(
        in_region_name IN VARCHAR2,
        out_country_info OUT country_reg_curr_table
        ) IS 
    
        -- The cursor is a query that returns a result set, which is a collection of rows
        CURSOR countries_region IS
        SELECT c.country_name,
            r.region_name,
            curr.currency_name
        FROM countries c,
            regions r,
            currencies curr
        WHERE c.region_id = r.region_id
            AND c.currency_code = curr.currency_code
            AND Lower(r.region_name) = Lower(in_region_name);

        i PLS_INTEGER := 1;

        -- The result set is iterated over and the rows are inserted into the associative array
        BEGIN 
            FOR country 
            IN countries_region 
            LOOP out_country_info(i) := country;
            i := i + 1;
        END LOOP;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(
            -20001,
            in_region_name || ' not found in the database.'
        );
    END;


    -- Procedure no. 4
    PROCEDURE print_region_array(
        in_country_reg_curr_table country_reg_curr_table
        ) IS 

    BEGIN 
        -- The associative array is iterated over and the rows are printed
        FOR i IN in_country_reg_curr_table.FIRST..in_country_reg_curr_table.LAST 
        LOOP DBMS_OUTPUT.PUT_LINE(
            in_country_reg_curr_table(i).country_name || 
            ', ' || 
            in_country_reg_curr_table(i).region || 
            ', ' || 
            in_country_reg_curr_table(i).currency
        );
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            -- SQLERRM returns error message associated with the lastest executet statement
            DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
    END;

    -- Procedure no. 5
    PROCEDURE country_languages(
        in_country_name IN VARCHAR2,
        out_country_langs OUT country_languages_arr
    ) IS 
    
        -- Using a cursor, fetch data from the database
        CURSOR country_languages_cursor IS
        SELECT countries.country_name,
            languages.language_name,
            spokenlang.official
        FROM COUNTRIES countries,
            LANGUAGES languages,
            SPOKEN_LANGUAGES spokenlang
        WHERE Lower(countries.country_name) = Lower(in_country_name)
            AND countries.country_id = spokenlang.country_id
            AND spokenlang.language_id = languages.language_id;
    
        i PLS_INTEGER := 1;
    
    BEGIN 
        FOR country_language IN country_languages_cursor LOOP
            -- Assign the cursor data to an index of the array
            out_country_langs(i) := country_language;
            i := i + 1;
        END LOOP;
    
        EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            RAISE_APPLICATION_ERROR(-20001, in_country_name || ' not found in the database.');
    END;
    
    -- Procedure no. 6
    PROCEDURE print_language_array(country_languages country_languages_arr) IS 
        BEGIN 
            FOR i IN country_languages.FIRST..country_languages.LAST 
            LOOP 
                DBMS_OUTPUT.PUT_LINE(
                country_languages(i).country_name || 
                ', ' || 
                country_languages(i).language_name || 
                ', ' || 
                country_languages(i).official_language
                );
            END LOOP;

        EXCEPTION
            WHEN OTHERS THEN
                -- SQLERRM returns error message associated with the lastest executet statement
                DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
    END;

END;
/

---------------------------------------------------------------------------
---------------------- The second package specification -------------------
---------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE traveler_admin_package AS

    TYPE object_info IS RECORD(
        name USER_DEPENDENCIES.name%TYPE,
        type USER_DEPENDENCIES.type%TYPE,
        referenced_name USER_DEPENDENCIES.referenced_name%TYPE,
        referenced_type USER_DEPENDENCIES.referenced_type%TYPE
    );

    TYPE object_arr IS TABLE OF object_info INDEX BY PLS_INTEGER;

    PROCEDURE display_disabled_triggers;
    FUNCTION all_dependent_objects(object_name VARCHAR2) RETURN object_arr;
    PROCEDURE print_dependent_objects(objects IN object_arr);

END traveler_admin_package;
/

---------------------------------------------------------------------------
--------------------- The second package implementation -------------------
---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY traveler_admin_package AS

    -- Procedure no. 7
    PROCEDURE display_disabled_triggers IS
        BEGIN
            FOR trigger_rec IN (
                SELECT trigger_name, trigger_type, status
                FROM user_triggers
                WHERE status = 'DISABLED'
            )
            LOOP
                DBMS_OUTPUT.PUT_LINE(
                    trigger_rec.trigger_name || 
                    ' ' || 
                    trigger_rec.trigger_type || 
                    ' ' || 
                    trigger_rec.status);
            END LOOP;
    END;

    -- Procedure no. 8
    FUNCTION all_dependent_objects(object_name VARCHAR2) RETURN object_arr IS

        CURSOR object_cur IS 
            SELECT 
                name, 
                type, 
                referenced_name, 
                referenced_type
            FROM 
                USER_DEPENDENCIES 
            WHERE 
                lower(referenced_name) = lower(object_name);
            v_objects object_arr;

        i PLS_INTEGER := 1;

        BEGIN

            FOR v_object IN object_cur LOOP
                v_objects(i) := v_object;
                i := i + 1;
            END LOOP;

            IF v_objects IS NULL THEN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'No data found for ' || object_name
                );
            END IF;
            RETURN v_objects;

            EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);

        END;

    -- -- Procedure no. 9
    PROCEDURE print_dependent_objects(objects IN object_arr) IS 

        BEGIN
            FOR i IN objects.FIRST .. objects.LAST LOOP
                DBMS_OUTPUT.PUT_LINE(
                    'Name: ' ||
                    RPAD(objects(i).name, 31) || 
                    'Type: ' ||
                    RPAD(objects(i).type, 31) ||
                    'Referenced name: ' ||
                    RPAD(objects(i).referenced_name, 31) || 
                    'Referenced type: ' ||
                    RPAD(objects(i).referenced_type,31)
                );
            END LOOP;

            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        END;

END;
/