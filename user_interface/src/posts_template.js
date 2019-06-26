import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput, TextField , List, Datagrid} from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const PostTitle = ({ record }) => {
    return <span>Post {record ? `"${record.title}"` : ''}</span>;
};

const Header = ({ variable }) => {
    return(<div><hr></hr><h2>{variable}</h2></div>);
}

const Caption = ({ variable }) => {
    return(<div><em>{variable}</em></div>);
}

export const PostList = props => (
    <List {...props}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
        </Datagrid>
    </List>
);

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
                XXXXX
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
