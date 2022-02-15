function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    apiUrl: 'https://api.realworld.io/api'
  }
  if (env == 'dev') {
    config.userEmail = ''
    config.userPassword = ''
  }
  else if (env == 'qa') {
    config.userEmail = 'nguyetduong4264@fakegmail.com'
    config.userPassword = 'Kms@2022'
  }

  var token = karate.callSingle('classpath:helpers/CreateToken.feature', config).authToken
  karate.configure("headers", {Authorization: 'Token '+token})
  karate.configure('ssl', true)

  return config;
}