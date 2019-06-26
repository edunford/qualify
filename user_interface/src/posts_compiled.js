import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput } from 'react-admin';
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


export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
							<Header variable="var_1" />
							<Caption variable="..." />
								<TextInput source= "v1_evidence" label="evidence" />
								<DateInput source= "v1_publication_date" label="publication_date" />
								<SelectInput source= "v1_code" label="code" choices={[{ id: '1', name: '1'},{ id: '2', name: '2'},{ id: '3', name: '3'},{ id: '4', name: '4'}]} />
							<Header variable="var_2" />
							<Caption variable="..." />
								<TextInput source= "v2_evidence" label="evidence" />
								<DateInput source= "v2_publication_date" label="publication_date" />
								<SelectInput source= "v2_code" label="code" choices={[{ id: '1', name: '1'},{ id: '2', name: '2'},{ id: '3', name: '3'},{ id: '4', name: '4'}]} />
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
