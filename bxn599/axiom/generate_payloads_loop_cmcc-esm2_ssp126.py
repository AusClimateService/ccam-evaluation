from axiom.drs.payload import Payload

# Create a payload object
payload = Payload(

  # Specify a globbable path to the input files.
  input_files='/g/data/xv83/mxt599/ccam_cmcc-esm2_ssp126_aus-10i_12km/cordex/*.nc',

  # Specify the output directory (DRS structure will be built from here).
  output_directory='/g/data/xv83/mxt599/ccam_cmcc-esm2_ssp126_aus-10i_12km/drs_cordex',

  # Specify the model, project and domain keys to read from configuration.
  model='CMCC-CMCC-ESM2',
  project='CORDEX-CMIP6',
  domain='AUS-10i',

  # Specify the start and end years to process (these are usually the same).
  start_year=1951,
  end_year=1951,

  # Specify the variable names to process
  # This is optional, omitting will load the expected variables from the schema
  ##variables=['tasmax', 'tasmin'],

  # Specify the output frequency of the data (i.e. 1D, 6H, 1D or 1M)
  output_frequency='1D',

  # Any further keywords will be added to the processing context
  # as additional metadata.
  driving_experiment_name='ssp126',
  ensemble='r1i1p1f1',
  cordex=True,
  input_resolution=12.5,
  model_id='CSIRO-CCAM-2203',
  rcm_version_id='v1',
  contact='Marcus Thatcher (Marcus.Thatcher@csiro.au)',
  preprocessor='ccam',
  postprocessor='ccam'
  # ... and so on
)

# Write the payload to a file
#payload.to_json('./payload.json')
freql = ['1H', '6H', '1D', '1M']

for freq in freql:
  print(freq)
  payload.output_frequency = freq
  for year in range(2015,2100): #include an extra year
    payload.start_year = year
    payload.end_year = year
    payload.to_json(f'/g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km/{freq}-payload-{year}.json')
