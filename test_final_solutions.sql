-- Test for Procedure no. 1
BEGIN traveler_assistance_package.country_demographics('Republic of Poland');
END;

SELECT 
    country_name,
    location,
    capitol,
    population,
    airports,
    climate
FROM countries WHERE country_name = 'Republic of Poland';

-- Test for Procedure no. 2
DECLARE
  v_country_reg_curr traveler_assistance_package.country_reg_curr_info;
BEGIN
  traveler_assistance_package.find_region_and_currency('Republic of Poland', v_country_reg_curr);
END;

SELECT countries.country_name,
        regions.region_name,
        currencies.currency_name
FROM   countries countries,
        regions regions,
        currencies currencies
WHERE  countries.country_name = 'Republic of Poland'
        AND countries.region_id = regions.region_id
        AND countries.currency_code = currencies.currency_code;


-- Test for Procedure no. 3
DECLARE
  v_region_name VARCHAR2(50) := 'Caribbean';
  v_country_info traveler_assistance_package.country_reg_curr_arr;
BEGIN
  traveler_assistance_package.countries_in_region(v_region_name, v_country_info);
  traveler_assistance_package.print_region_array(v_country_info);
END;

SELECT c.country_name,
     r.region_name,
     curr.currency_name
FROM   countries c,
     regions r,
     currencies curr
WHERE  c.region_id = r.region_id
     AND c.currency_code = curr.currency_code
     AND r.region_name = 'Caribbean';

-- Test for Procedure no. 4
DECLARE
  v_country_reg_curr_arr traveler_assistance_package.country_reg_curr_arr;
BEGIN

  v_country_reg_curr_arr(1).country_name := 'United States';
  v_country_reg_curr_arr(1).region := 'North America';
  v_country_reg_curr_arr(1).currency := 'USD';
  
  v_country_reg_curr_arr(2).country_name := 'Canada';
  v_country_reg_curr_arr(2).region := 'North America';
  v_country_reg_curr_arr(2).currency := 'CAD';
  
  traveler_assistance_package.Print_region_array(v_country_reg_curr_arr);
END;

-- Test for Procedure no. 5
DECLARE
  v_country_name VARCHAR2(50) := 'Republic of Poland';
  v_country_langs traveler_assistance_package.country_lang_arr;
BEGIN
  traveler_assistance_package.country_languages(v_country_name, v_country_langs);
END;

SELECT countries.country_name,
       languages.language_name,
       spoken_languages.official
FROM   countries
JOIN   spoken_languages ON countries.country_id = spoken_languages.country_id
JOIN   languages ON spoken_languages.language_id = languages.language_id
WHERE  LOWER(countries.country_name) = LOWER('Republic of Poland');

-- Test for Procedure no. 6
DECLARE
  v_country_languages traveler_assistance_package.country_lang_arr;
BEGIN
    -- Populate the country_languages array with test data
    v_country_languages(1).country_name := 'Republic of Poland';
    v_country_languages(1).language_name := 'Polish';
    v_country_languages(1).official_language := 'Y';
    
    v_country_languages(2).country_name := 'Germany';
    v_country_languages(2).language_name := 'German';
    v_country_languages(2).official_language := 'Y';
    
    v_country_languages(3).country_name := 'The Netherlands';
    v_country_languages(3).language_name := 'Dutch';
    v_country_languages(3).official_language := 'Y';
    
  -- Call the Print_language_array procedure
traveler_assistance_package.Print_language_array(v_country_languages);
END;

-- Test for Procedure no. 7
CREATE OR REPLACE TRIGGER some_trigger
BEFORE INSERT ON countries
FOR EACH ROW
DISABLE
BEGIN
NULL; -- do nothing
END;

BEGIN
  traveler_admin_package.display_disabled_triggers;
END;

DROP TRIGGER some_trigger;

-- No triggers found
BEGIN
  traveler_admin_package.display_disabled_triggers;
END;

-- Testing the function no. 8
-- Test for All_dependent_objects function

DECLARE
  v_objects traveler_admin_package.object_arr;
BEGIN
  v_objects := traveler_admin_package.All_dependent_objects('EMPLOYEES');

  FOR i IN v_objects.FIRST .. v_objects.LAST LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Name: ' || v_objects(i).name ||
      ', Type: ' || v_objects(i).TYPE ||
      ', Referenced Name: ' || v_objects(i).referenced_name ||
      ', Referenced Type: ' || v_objects(i).referenced_type
    );
  END LOOP;
END;

-- Test for Procedure no. 9
-- Since a view exists that depends on the employees table

DECLARE
  v_object_name VARCHAR2(50) := 'EMPLOYEES';
  v_objects traveler_admin_package.object_arr;
BEGIN
  v_objects := traveler_admin_package.all_dependent_objects(v_object_name);
  traveler_admin_package.print_dependent_objects(v_objects);
END;

