import React from 'react';
import { Redirect } from 'react-router'
import { Admin, Resource } from 'react-admin';
import simpleRestProvider from 'ra-data-simple-rest';

import { PostCreate } from './posts';

const App = () => (
    <Admin dataProvider={simpleRestProvider('http://localhost:8000')}>
        <Resource name="posts" create={PostCreate} />
        <Redirect from="/" to="/posts/create" />
    </Admin>
);

export default App;