const exec = require('child_process').exec;
const fs = require('fs');
const uuid = require('node-uuid');
const archiver = require('archiver');
const aws = require('aws-sdk');
const s3 = new aws.S3({ apiVersion: '2006-03-01' });

const TMP_DIR_PATH = `/tmp/${uuid.v4()}`;
const PACKAGE_JSON_PATH = `${TMP_DIR_PATH}/package.json`;
const MODULES_PATH = `${TMP_DIR_PATH}/node_modules`;
const DUMMY_HOME_PATH = `/tmp/${uuid.v4()}`;
const ZIP_FILE_PATH = `/tmp/${uuid.v4()}`;

function handler(event, context, callback) {
  new Promise((resolve, reject) => {
    if (!fs.existsSync(TMP_DIR_PATH)) {
      fs.mkdirSync(TMP_DIR_PATH);
    }
    if (!fs.existsSync(DUMMY_HOME_PATH)) {
      fs.mkdirSync(DUMMY_HOME_PATH);
    }
    fs.writeFileSync(PACKAGE_JSON_PATH, JSON.stringify(event, null, 2));

    exec(`HOME=${DUMMY_HOME_PATH} npm install`, { cwd: TMP_DIR_PATH }, (err, stdout, stderr) => {
      if (err) {
        reject(err);
      } else {
        resolve({
          bucket: event['clairlune']['bucket'],
          key: event['clairlune']['key'],
        });
      }
    });
  }).then(data => {
    return new Promise((resolve, reject) => {
      const output = fs.createWriteStream(ZIP_FILE_PATH);
      const archive = archiver('zip');

      archive.pipe(output);
      archive.bulk([
        { expand: true, cwd: MODULES_PATH, src: ['**/*'], dest: '/', dot: true }
      ]);

      output.on('close', () => {
        resolve(data);
      });
      archive.on('error', (err) => {
        reject(err);
      });

      archive.finalize();
    });
  }).then((data) => {
    const fileStream = fs.createReadStream(ZIP_FILE_PATH);

    fileStream.on('error', (err) => {
      context.fail(err);
    });

    fileStream.on('open', () => {
      const s3Params = {
        Bucket: data['bucket'],
        Key: data['key'],
        Body: fileStream,
      };

      s3.putObject(s3Params, (err, _) => {
        if (err) {
          context.fail(err);
        } else {
          context.succeed({
            status: 'success',
            bucket: data['bucket'],
            key: data['key'],
          });
        }
      });
    });
  }).catch(err => {
    context.fail(err);
  });
}

exports.handler = handler;
