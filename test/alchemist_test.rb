# encoding: UTF-8

$:.unshift(File.dirname(__FILE__) + '../lib')

require 'test/unit'
require 'alchemist'

class Float
  # truncates float to specified decimal places
  def truncate(dec = 0)
    return to_i if dec == 0
    sprintf("%.#{dec}f", self).to_f
  end
end

class AlchemistTest < Test::Unit::TestCase

  def test_equivalence
    assert_equal(1.m, 1.meter)
  end

  def test_bit_and_bytes
    assert_equal( 65.bit.to_f,  (1.bit + 8.bytes).to_f )
    assert_equal( 0.125.bytes.to_f, 1.bit.to.bytes.to_f )
    assert_in_delta(1.MB.to.kB.to_f, 1024.0, 1e-5)
    assert_in_delta(1.MB.to.b.to_f, 8388608.0, 1e-5)
    assert_in_delta(1.GB.to.B.to_f, 1073741824.0, 1e-5)
    assert_in_delta(1.MiB.to.KiB.to_f, 1024.0, 1e-5)
    assert_in_delta(1.MiB.to.b.to_f, 8388608.0, 1e-5)
    assert_in_delta(1.GiB.to.B.to_f, 1073741824.0, 1e-5)
    Alchemist::use_si = true
    assert_in_delta(1.GB.to.B.to_f, 1000000000.0, 1e-5)
    assert_in_delta(1.MB.to.b.to_f, 8000000.0, 1e-5)
    assert_in_delta(1.MB.to.kB.to_f, 1000.0, 1e-5)
  end

  def test_feet_to_miles
    assert_equal( 5280.feet,  1.mile.to.feet )
  end

  def test_acre_to_yards_squared
    assert_in_delta( 4840.square_yards.to_f,  1.acre.to.square_yards.to_f, 1e-5)
  end

  def test_gallon_to_liter
    assert_in_delta( 3.785411784.L.to_f, 1.gallon.to.L.to_f, 1e-5 )
  end

  def test_lb_to_kg
    assert_equal( 0.45359237.kg.to_f, 1.lb.to.kg.to_f )
  end

  def test_comparison
    assert_equal( 5.grams, 0.005.kilograms )
  end

  def test_register
    Alchemist.register(:distance, [:beard_second, :beard_seconds], 5.angstroms)
    assert_equal( 1.beard_second, 5.angstroms)
    Alchemist.register(:temperature, :yeti, [Proc.new{|t| t + 1}, Proc.new{|t| t - 1}])
    assert_equal( 0.yeti, 1.kelvin)
  end

  def test_meters_times_meters
    assert_equal(1.meter * 1.meter, 1.square_meter)
  end

  def test_meters_times_meters_times_meters
    assert_equal(1.meter * 2.meter * 3.meter, 6.cubic_meters)
    assert_equal(2.square_meters * 3.meters, 6.cubic_meters)
  end

  def test_division
    assert_equal(2.meters / 1.meters, 2.0)
  end

  def test_temperature
    assert_equal(1.fahrenheit, 1.fahrenheit)
    assert_in_delta(1.fahrenheit.to_f, 1.fahrenheit.to.celsius.to.fahrenheit.to_f, 1e-5)
  end

  def test_density
    assert_equal(25.brix.to_f, 1.1058.sg.to.brix.value.truncate(1))
    assert_equal(25.brix, 13.87.baume.truncate(1))
    assert_equal(25.plato, 25.125.brix)
  end

  def test_is_si_unit
    assert Alchemist.is_si_unit?("meter")
    assert !Alchemist.is_si_unit?("foot")
  end

  def test_is_valid_unit
    assert Alchemist.is_valid_unit?("meter")
    assert Alchemist.is_valid_unit?("foot")
    assert !Alchemist.is_valid_unit?("foobar")
  end

  def test_is_compatible_unit
    assert Alchemist.is_compatible_unit?("kelvin", "celsius")
    assert Alchemist.is_compatible_unit?("fahrenheit", "celsius")
    assert !Alchemist.is_compatible_unit?("fahrenheit", "foobar")
    assert !Alchemist.is_compatible_unit?("foobar", "foobar")
    assert !Alchemist.is_compatible_unit?("kelvin", "meter")
  end

  def test_dBm
    assert 1.watt.to.dBm.value == 30
    assert 0.dBm.to.watt.value == 0.001
  end

  def test_conversion_with_proc_resultis_in_instance_of_numeric_conversion
    assert 1.watt.to.dBm.class == Alchemist::NumericConversion
    assert 1.watt.to.dBm.unit_name.to_s == "dBm"
  end

  def test_i18n
    I18n.locale = "en"
    assert 1.celsius.unit_name_t == "degree Celsius"
    assert 2.celsius.unit_name_t == "degrees Celsius"
    assert 1.celsius.unit_symbol_t == "°C"
    I18n.locale = "de"
    assert 1.celsius.unit_name_t == "Grad Celsius"
    assert 2.celsius.unit_name_t == "Grad Celsius"
    assert 1.celsius.unit_symbol_t == "°C"
  end

  def test_to_s
    I18n.locale = "en"
    assert 1.celsius.to_s == "1.0 °C"
  end

  def test_to_regional_unit
    assert 10.kelvin.to_regional_unit("us").unit_name.to_s == "fahrenheit"
    assert 10.kelvin.to_regional_unit("ch").unit_name.to_s == "celsius"
    # also works with locales:
    I18n.locale = "en"
    assert 10.kelvin.to_regional_unit("us").unit_name_t == "degrees Fahrenheit"
    assert 10.kelvin.to_regional_unit("ch").unit_name_t == "degrees Celsius"
    I18n.locale = "de"
    assert 10.kelvin.to_regional_unit("us").unit_name_t == "Grad Fahrenheit"
    assert 10.kelvin.to_regional_unit("ch").unit_name_t == "Grad Celsius"
  end

  def test_units_respect_prefix
    I18n.locale = "en"
    assert 1.cm.unit_name_t.to_s == "centimeter"
    assert 10.cm.unit_name_t.to_s == "centimeters"
    I18n.locale = "de"
    assert 1.cm.unit_name_t.to_s == "Zentimeter"
    assert 10.cm.unit_name_t.to_s == "Zentimeter"
  end

  def test_prefix_convertion_works
    I18n.locale = "en"
    assert 1.m.to.cm.unit_name_t.to_s == "centimeters"
    assert 1.m.to.cm.to_f == 100.0
    assert 1.m.to.cm.to.m.to_f == 1.0
    assert 1.km.to.cm.to.m.to_f == 1000.0
  end

  def test_prefix_operations_convert_to_default_type
    I18n.locale = "en"
    assert (1.m + 1.cm).unit_name_t.to_s == "meters"
    assert (1.m + 1.cm).to_f == 1.01
    assert (1.cm + 1.m).unit_name_t.to_s == "meters"
    assert (1.cm + 1.m).to_f == 1.01
    assert (1.cm + 1.km).unit_name_t.to_s == "meters"
    assert (1.cm + 1.km).to_f == 1000.01
  end

  def test_dimensionless_units
    I18n.locale = "en"
    assert 1.unitless.to_s == "1.0 "
    assert 0.5.unitless.to.percent.to_f == 50
    assert 0.5.unitless.to.percent.to_s == "50.0 %"
    assert 0.5.unitless.to.percent.unit_name_t == "percent"
    assert 0.5.unitless.to.per_mille.to_f == 500
    assert 0.5.unitless.to.per_mille.to_s == "500.0 ‰"
    assert 0.5.unitless.to.per_mille.to_s == "500.0 ‰"
    assert 0.000001.unitless.to.parts_per_million.to_f == 1
    assert 0.000001.unitless.to.parts_per_million.to_s == "1.0 ppm"
    assert 100.unitless.to.bel.to_f == 2
    assert 1000.unitless.to.decibel.to_f == 30
    assert 1000.unitless.to.decibel.to_s == "30.0 dB"
  end

  def test_pf_value
    assert 1000.pascal.to.pf_value.to_f == 1
    assert 3.pf_value.to.pascal.to_f == 100000
    assert_in_delta(2.123.pf_value.to_f, 2.123.pf_value.to.pascal.to.pf_value.to_f, 1e-10)

    I18n.locale = "en"
    assert 1.pf_value.unit_name_t.to_s == "pF-value"
    assert 1.pf_value.unit_symbol_t == "pF"

    I18n.locale = "de"
    assert 1.pf_value.unit_name_t.to_s == "pF-Wert"
    assert 1.pf_value.unit_symbol_t == "pF"
  end

  def test_pressure
    I18n.locale = "en"
    assert 1.pascal.to_regional_unit('ch').unit_name_t.to_s == "pascal"
    assert 2.pascal.to_regional_unit('ch').unit_name_t.to_s == "pascals"
    assert 1.pascal.to_regional_unit('us').unit_name_t.to_s == "pounds per square inch"
    I18n.locale = "de"
    assert 1.pascal.to_regional_unit('ch').unit_name_t.to_s == "Pascal"
    assert 2.pascal.to_regional_unit('ch').unit_name_t.to_s == "Pascal"
    assert 1.pascal.to_regional_unit('us').unit_name_t.to_s == "pounds per square inch"
  end

end

