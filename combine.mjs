import fs from 'fs/promises';
import yaml from './js-yaml.mjs';

const files = process.argv.slice(2);

function add(target, value, key) {
  if (Array.isArray(value)) {
    if (!target.hasOwnProperty(key)) target[key] = [];
    target[key] = [...target[key], ...value];
  } else if (typeof value === 'object') {
    if (!target.hasOwnProperty(key)) target[key] = {};
    Object.keys(value).forEach(k => {
      add(target[key], value[k], k);
    });
  } else {
    target[key] = value;
  }
}

const allFiles = await Promise.all(files.map(file => fs.readFile(file).then(f => {
  try {
    return yaml.load(String(f));
  } catch(e) {
    console.error(e);
  }
})));

const combined = {
  info: {
    title: '123',
    version: '0.0.1',
  },
  tags: [],
};

const skipKeys = ['info', 'tags'];
allFiles.forEach((spec, i) => {
  if (!spec) return;
  combined.tags.push({
    name: String(i),
    description: spec.info.title,
  });
  Object.values(spec.paths).forEach(pathObj => {
    Object.values(pathObj).forEach(methodObj => {
      methodObj.tags = [String(i)];
    })
  });
  Object.keys(spec).forEach(key => {
    if (skipKeys.includes(key)) return;
    add(combined, spec[key], key);
  });
});

fs.writeFile('combined.json', JSON.stringify(combined, null, 2));