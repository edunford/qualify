import React from 'react';
import { Admin, Resource } from 'react-admin';
import jsonServerProvider from 'ra-data-json-server';

import { PostEdit, PostList } from './posts_compiled';
import MyLayout from './CustomLayout';

const App = () => (
    <Admin appLayout={MyLayout} title="Qualify" dataProvider={jsonServerProvider('http://localhost:8000')}>
        <Resource name="posts" options={{ label: 'Records' }} list={PostList} edit={PostEdit} />
    </Admin>
);

export default App;
