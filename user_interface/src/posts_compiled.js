import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput } from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const PostTitle = ({ record }) => {
    return <span>Post {record ? `"${record.title}"` : ''}</span>;
};

const Header = ({ variable }) => {
    return(<div><h3>{variable}</h3>
            <hr></hr></div>);
}

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
<Header variable="var_1" />
<TextInput source= "evidence" />
<DateInput source= "publication_date" />
<SelectInput source= "code" choices={[{ id: '1'},{ id: '2'},{ id: '3'},{ id: '4'}]} />
<Header variable="var_2" />
<TextInput source= "evidence" />
<DateInput source= "publication_date" />
<SelectInput source= "code" choices={[{ id: '1'},{ id: '2'},{ id: '3'},{ id: '4'}]} />
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
