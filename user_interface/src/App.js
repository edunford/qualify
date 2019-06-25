import React from 'react';
import { Admin, Resource, ListGuesser } from 'react-admin';
import jsonServerProvider from 'ra-data-json-server';

import { PostCreate } from './posts';

const App = () => (
    <Admin dataProvider={jsonServerProvider('http://localhost:8000')}>
        <Resource name="posts" list={ListGuesser} />
    </Admin>
);

export default App;