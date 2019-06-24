import React from 'react';
import { Admin, Resource } from 'react-admin';
import simpleRestProvider from 'ra-data-simple-rest';

import { PostCreate } from './posts';

const App = () => (
    <Admin dataProvider={simpleRestProvider('http://127.0.0.1:8000')}>
        <Resource name="posts" create={PostCreate} />
    </Admin>
);

export default App;